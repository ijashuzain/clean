import 'package:logit/core/failure/failure.dart';
import 'package:logit/core/utils/result/result.dart';
import 'package:logit/features/task/data/datasources/local/task_local_datasource.dart';
import 'package:logit/features/task/data/datasources/remote/task_remote_datasource.dart';
import 'package:logit/features/task/data/models/task_model/task_model.dart';
import 'package:logit/features/task/domain/entities/task/task.dart';
import 'package:logit/features/task/domain/repositories/task_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_repository_impl.g.dart';

@riverpod
TaskRepository taskRepository(Ref ref) {
  return TaskRepositoryImpl(
    localDataSource: ref.watch(taskLocalDataSourceProvider),
    remoteDataSource: ref.watch(taskRemoteDataSourceProvider),
  );
}

class TaskRepositoryImpl implements TaskRepository {
  static const String _dailyOccurrenceSeparator = '__occ__';

  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Result<List<Task>>> getAllTasks() async {
    try {
      await _safeSyncRemoteAndLocal();
      final tasks =
          (await localDataSource.getTasks())
              .map((task) => task.toEntity())
              .toList(growable: false)
            ..sort(_sortByTimeThenCreation);
      return Result.success(tasks);
    } catch (e) {
      return Result.failure(Failure.cacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Task>>> getTasksByDate(DateTime date) async {
    try {
      await _safeSyncRemoteAndLocal();
      final targetDate = _toDateOnly(date);
      final tasksForDate = await _resolveTasksForDate(
        targetDate,
        materializeDailyOccurrences: true,
      );
      return Result.success(
        tasksForDate.map((task) => task.toEntity()).toList(growable: false),
      );
    } catch (e) {
      return Result.failure(Failure.cacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> upsertTask(Task task) async {
    try {
      final model = TaskModel.fromEntity(task);
      await localDataSource.upsertTask(model);
      await _safeUpsertRemote(model);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(Failure.cacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Map<String, List<String>>>> getEmojiPreviewForRange({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      await _safeSyncRemoteAndLocal();
      final allTasks = await localDataSource.getTasks();
      final start = DateTime(from.year, from.month, from.day);
      final end = DateTime(to.year, to.month, to.day);
      final emojiMap = <String, List<String>>{};

      var cursor = start;
      while (!cursor.isAfter(end)) {
        final emojis = <String>[];
        final tasksForDate = await _resolveTasksForDate(
          cursor,
          materializeDailyOccurrences: false,
          allTasks: allTasks,
        );
        for (final task in tasksForDate) {
          final icon = task.iconKey.trim();
          if (!_isEmoji(icon)) {
            continue;
          }
          emojis.add(icon);
          if (emojis.length >= 4) {
            break;
          }
        }

        if (emojis.isNotEmpty) {
          emojiMap[_dateKey(cursor)] = emojis;
        }
        cursor = cursor.add(const Duration(days: 1));
      }

      return Result.success(emojiMap);
    } catch (e) {
      return Result.failure(Failure.cacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> toggleTaskCompletion({
    required String taskId,
    DateTime? forDate,
    String? subTaskId,
  }) async {
    try {
      await _safeSyncRemoteAndLocal();
      final task = await localDataSource.getTaskById(taskId);
      if (task == null) {
        return Result.failure(Failure.clientFailure(message: 'Task not found'));
      }

      final entity = task.toEntity();
      final today = _toDateOnly(DateTime.now());
      final targetDate = _toDateOnly(forDate ?? entity.scheduledAt);
      if (targetDate.isAfter(today)) {
        return Result.failure(
          Failure.clientFailure(
            message: 'Future tasks cannot be completed yet',
          ),
        );
      }
      if (_isLockedCompletedPastTask(entity)) {
        return Result.failure(
          Failure.clientFailure(
            message: 'Completed tasks from previous days cannot be unchecked',
          ),
        );
      }
      final updated = _toggleEntity(entity, subTaskId: subTaskId);
      final updatedModel = TaskModel.fromEntity(updated);
      await localDataSource.upsertTask(updatedModel);
      await _safeUpsertRemote(updatedModel);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(Failure.cacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteTask(String taskId) async {
    try {
      await _safeSyncRemoteAndLocal();
      final allTasks = await localDataSource.getTasks();
      final sourceId = _sourceIdFromOccurrenceId(taskId);

      if (sourceId != null) {
        final idsToDelete = allTasks
            .where(
              (task) =>
                  task.id == sourceId ||
                  _sourceIdFromOccurrenceId(task.id) == sourceId,
            )
            .map((task) => task.id)
            .toSet();
        if (idsToDelete.isEmpty) {
          idsToDelete.add(taskId);
        }
        for (final id in idsToDelete) {
          await localDataSource.deleteTask(id);
          await _safeDeleteRemote(id);
        }
        return const Result.success(null);
      }

      TaskModel? rootTask;
      for (final task in allTasks) {
        if (task.id == taskId) {
          rootTask = task;
          break;
        }
      }
      if (rootTask != null && _isDailyTemplate(rootTask)) {
        final idsToDelete = allTasks
            .where(
              (task) =>
                  task.id == taskId ||
                  _sourceIdFromOccurrenceId(task.id) == taskId,
            )
            .map((task) => task.id)
            .toSet();
        for (final id in idsToDelete) {
          await localDataSource.deleteTask(id);
          await _safeDeleteRemote(id);
        }
        return const Result.success(null);
      }

      await localDataSource.deleteTask(taskId);
      await _safeDeleteRemote(taskId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(Failure.cacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Task?>> getTaskById(String taskId) async {
    try {
      await _safeSyncRemoteAndLocal();
      final task = await localDataSource.getTaskById(taskId);
      return Result.success(task?.toEntity());
    } catch (e) {
      return Result.failure(Failure.cacheFailure(message: e.toString()));
    }
  }

  Future<void> _safeSyncRemoteAndLocal() async {
    try {
      await _syncRemoteAndLocal();
    } catch (_) {
      // Keep local-first behavior even when remote is unavailable.
    }
  }

  Future<void> _syncRemoteAndLocal() async {
    final remoteUserId = remoteDataSource.currentUserId;
    if (remoteUserId == null || !remoteDataSource.canSync) {
      return;
    }

    final previousSyncedUserId = await localDataSource.getSyncedUserId();
    if (previousSyncedUserId != null && previousSyncedUserId != remoteUserId) {
      await localDataSource.replaceAllTasks(const <TaskModel>[]);
    }
    if (previousSyncedUserId != remoteUserId) {
      await localDataSource.setSyncedUserId(remoteUserId);
    }

    final localTasks = await localDataSource.getTasks();
    final remoteTasks = await remoteDataSource.fetchTasks();
    final remoteById = <String, TaskModel>{
      for (final task in remoteTasks) task.id: task,
    };
    final mergedById = <String, TaskModel>{...remoteById};

    for (final localTask in localTasks) {
      final remoteTask = remoteById[localTask.id];
      if (remoteTask == null) {
        mergedById[localTask.id] = localTask;
        await remoteDataSource.upsertTask(localTask);
        continue;
      }

      if (localTask.updatedAt.isAfter(remoteTask.updatedAt) ||
          localTask.updatedAt.isAtSameMomentAs(remoteTask.updatedAt)) {
        mergedById[localTask.id] = localTask;
        await remoteDataSource.upsertTask(localTask);
        continue;
      }

      mergedById[localTask.id] = remoteTask;
    }

    final mergedTasks = mergedById.values.toList(
      growable: false,
    )..sort((first, second) => first.scheduledAt.compareTo(second.scheduledAt));
    await localDataSource.replaceAllTasks(mergedTasks);
  }

  Future<void> _safeUpsertRemote(TaskModel task) async {
    if (!remoteDataSource.canSync) {
      return;
    }
    try {
      await remoteDataSource.upsertTask(task);
    } catch (_) {
      // Best effort, local data remains the source of truth while offline.
    }
  }

  Future<void> _safeDeleteRemote(String taskId) async {
    if (!remoteDataSource.canSync) {
      return;
    }
    try {
      await remoteDataSource.deleteTask(taskId);
    } catch (_) {
      // Best effort, local delete already succeeded.
    }
  }

  Task _toggleEntity(Task task, {String? subTaskId}) {
    if (subTaskId == null) {
      final toggled = !task.isCompleted;
      return task.copyWith(
        isCompleted: toggled,
        subtasks: task.subtasks
            .map((item) => item.copyWith(isCompleted: toggled))
            .toList(growable: false),
        updatedAt: DateTime.now(),
      );
    }

    final updatedSubTasks = task.subtasks
        .map((subtask) {
          if (subtask.id != subTaskId) {
            return subtask;
          }
          return subtask.copyWith(isCompleted: !subtask.isCompleted);
        })
        .toList(growable: false);

    final allDone =
        updatedSubTasks.isNotEmpty &&
        updatedSubTasks.every((subtask) => subtask.isCompleted);

    return task.copyWith(
      subtasks: updatedSubTasks,
      isCompleted: allDone,
      updatedAt: DateTime.now(),
    );
  }

  Future<List<TaskModel>> _resolveTasksForDate(
    DateTime date, {
    required bool materializeDailyOccurrences,
    List<TaskModel>? allTasks,
  }) async {
    final targetDate = _toDateOnly(date);
    final today = _toDateOnly(DateTime.now());
    final sourceTasks = (allTasks ?? await localDataSource.getTasks()).toList(
      growable: true,
    );

    final templateIds = sourceTasks
        .where((task) => !_isDailyOccurrence(task))
        .map((task) => task.id)
        .toSet();
    final occurrenceBySource = <String, TaskModel>{};

    for (final task in sourceTasks) {
      if (!_isDailyOccurrence(task)) {
        continue;
      }
      if (!_isSameDate(_toDateOnly(task.scheduledAt), targetDate)) {
        continue;
      }
      final sourceId = _sourceIdFromOccurrenceId(task.id);
      if (sourceId != null) {
        occurrenceBySource[sourceId] = task;
      }
    }

    final tasksForDate = <TaskModel>[];
    final pendingUpserts = <TaskModel>[];

    for (final task in sourceTasks) {
      if (_isDailyOccurrence(task)) {
        continue;
      }

      final startDate = _toDateOnly(task.scheduledAt);
      final endDate = task.endDate == null ? null : _toDateOnly(task.endDate!);

      if (_isDailyTemplate(task)) {
        if (targetDate.isBefore(startDate)) {
          continue;
        }
        if (endDate != null && targetDate.isAfter(endDate)) {
          continue;
        }

        var normalizedTemplate = task;
        final shouldResetTemplateCompletion =
            task.isCompleted ||
            task.subtasks.any((subtask) => subtask.isCompleted);
        if (shouldResetTemplateCompletion) {
          normalizedTemplate = task.copyWith(
            isCompleted: false,
            subtasks: task.subtasks
                .map((subtask) => subtask.copyWith(isCompleted: false))
                .toList(growable: false),
            updatedAt: DateTime.now(),
          );
          pendingUpserts.add(normalizedTemplate);
        }

        if (targetDate.isAfter(today)) {
          tasksForDate.add(normalizedTemplate);
          continue;
        }

        var occurrence = occurrenceBySource[normalizedTemplate.id];
        if (occurrence == null && materializeDailyOccurrences) {
          occurrence = _buildDailyOccurrence(
            source: normalizedTemplate,
            date: targetDate,
          );
          occurrenceBySource[normalizedTemplate.id] = occurrence;
          pendingUpserts.add(occurrence);
        }

        if (occurrence != null) {
          tasksForDate.add(occurrence);
        } else {
          tasksForDate.add(normalizedTemplate);
        }
        continue;
      }

      if (_shouldShowNonDailyOnDate(
        task: task,
        scheduledDate: startDate,
        endDate: endDate,
        date: targetDate,
      )) {
        tasksForDate.add(task);
      }
    }

    for (final occurrence in sourceTasks.where(_isDailyOccurrence)) {
      final sourceId = _sourceIdFromOccurrenceId(occurrence.id);
      if (sourceId == null || templateIds.contains(sourceId)) {
        continue;
      }
      if (_isSameDate(_toDateOnly(occurrence.scheduledAt), targetDate)) {
        tasksForDate.add(occurrence);
      }
    }

    if (materializeDailyOccurrences && pendingUpserts.isNotEmpty) {
      for (final task in pendingUpserts) {
        await localDataSource.upsertTask(task);
        await _safeUpsertRemote(task);
      }
    }

    tasksForDate.sort(
      (first, second) =>
          _sortByTimeThenCreation(first.toEntity(), second.toEntity()),
    );
    return tasksForDate.toList(growable: false);
  }

  bool _shouldShowNonDailyOnDate({
    required TaskModel task,
    required DateTime scheduledDate,
    required DateTime? endDate,
    required DateTime date,
  }) {
    if (date.isBefore(scheduledDate)) {
      return false;
    }

    if (_shouldCarryForwardUnfinishedTask(
      task: task,
      scheduledDate: scheduledDate,
      endDate: endDate,
      date: date,
    )) {
      return true;
    }

    if (endDate != null && date.isAfter(endDate)) {
      return false;
    }

    if (endDate != null) {
      return true;
    }

    return _isSameDate(scheduledDate, date);
  }

  bool _shouldCarryForwardUnfinishedTask({
    required TaskModel task,
    required DateTime scheduledDate,
    required DateTime? endDate,
    required DateTime date,
  }) {
    if (_isDailyTemplate(task)) {
      return false;
    }
    if (_isTaskFinishedModel(task)) {
      return false;
    }
    final today = _toDateOnly(DateTime.now());
    if (!_isSameDate(date, today)) {
      return false;
    }
    if (endDate != null && !endDate.isBefore(today)) {
      return false;
    }
    return scheduledDate.isBefore(today);
  }

  bool _isLockedCompletedPastTask(Task task) {
    if (!_isTaskFinished(task)) {
      return false;
    }
    final today = _toDateOnly(DateTime.now());
    final start = _toDateOnly(task.scheduledAt);
    final end = task.endDate == null ? start : _toDateOnly(task.endDate!);
    return end.isBefore(today);
  }

  DateTime _toDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isDailyOccurrence(TaskModel task) {
    return _sourceIdFromOccurrenceId(task.id) != null;
  }

  bool _isDailyTemplate(TaskModel task) {
    return task.repeatsDaily &&
        task.endDate == null &&
        !_isDailyOccurrence(task);
  }

  String? _sourceIdFromOccurrenceId(String id) {
    final separatorIndex = id.lastIndexOf(_dailyOccurrenceSeparator);
    if (separatorIndex <= 0) {
      return null;
    }
    final suffix = id.substring(
      separatorIndex + _dailyOccurrenceSeparator.length,
    );
    if (suffix.length != 8 || int.tryParse(suffix) == null) {
      return null;
    }
    return id.substring(0, separatorIndex);
  }

  TaskModel _buildDailyOccurrence({
    required TaskModel source,
    required DateTime date,
  }) {
    final normalizedDate = _toDateOnly(date);
    final now = DateTime.now();
    return source.copyWith(
      id: '${source.id}$_dailyOccurrenceSeparator${_yyyymmdd(normalizedDate)}',
      scheduledAt: normalizedDate,
      endDate: null,
      isCompleted: false,
      subtasks: source.subtasks
          .map((subtask) => subtask.copyWith(isCompleted: false))
          .toList(growable: false),
      reminders: const <TaskReminderModel>[],
      reminderDate: null,
      reminderMinuteOfDay: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  String _yyyymmdd(DateTime date) {
    final yyyy = date.year.toString().padLeft(4, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$yyyy$mm$dd';
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  bool _isEmoji(String value) {
    if (value.isEmpty) {
      return false;
    }
    return value.runes.any((rune) => rune > 127);
  }

  bool _isTaskFinished(Task task) {
    if (task.isCompleted) {
      return true;
    }
    return task.subtasks.isNotEmpty &&
        task.subtasks.every((subtask) => subtask.isCompleted);
  }

  bool _isTaskFinishedModel(TaskModel task) {
    if (task.isCompleted) {
      return true;
    }
    return task.subtasks.isNotEmpty &&
        task.subtasks.every((subtask) => subtask.isCompleted);
  }

  String _dateKey(DateTime date) {
    final yyyy = date.year.toString().padLeft(4, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  int _sortByTimeThenCreation(Task first, Task second) {
    final firstMinute = first.startMinuteOfDay ?? 1440;
    final secondMinute = second.startMinuteOfDay ?? 1440;
    if (firstMinute != secondMinute) {
      return firstMinute.compareTo(secondMinute);
    }
    return first.createdAt.compareTo(second.createdAt);
  }
}
