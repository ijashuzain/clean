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
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Result<List<Task>>> getAllTasks() async {
    try {
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
      final targetDate = DateTime(date.year, date.month, date.day);
      final allTasks = await localDataSource.getTasks();
      final tasksForDate =
          allTasks
              .where((task) => _shouldShowOnDate(task, targetDate))
              .map((task) => task.toEntity())
              .toList()
            ..sort(_sortByTimeThenCreation);

      return Result.success(tasksForDate);
    } catch (e) {
      return Result.failure(Failure.cacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> upsertTask(Task task) async {
    try {
      await localDataSource.upsertTask(TaskModel.fromEntity(task));
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
      final allTasks = await localDataSource.getTasks();
      final start = DateTime(from.year, from.month, from.day);
      final end = DateTime(to.year, to.month, to.day);
      final emojiMap = <String, List<String>>{};

      var cursor = start;
      while (!cursor.isAfter(end)) {
        final emojis = <String>[];
        for (final task in allTasks) {
          if (!_shouldShowOnDate(task, cursor)) {
            continue;
          }
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
    String? subTaskId,
  }) async {
    try {
      final task = await localDataSource.getTaskById(taskId);
      if (task == null) {
        return Result.failure(Failure.clientFailure(message: 'Task not found'));
      }

      final entity = task.toEntity();
      if (_isLockedCompletedPastTask(entity)) {
        return Result.failure(
          Failure.clientFailure(
            message: 'Completed tasks from previous days cannot be unchecked',
          ),
        );
      }
      final updated = _toggleEntity(entity, subTaskId: subTaskId);
      await localDataSource.upsertTask(TaskModel.fromEntity(updated));
      return const Result.success(null);
    } catch (e) {
      return Result.failure(Failure.cacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteTask(String taskId) async {
    try {
      await localDataSource.deleteTask(taskId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(Failure.cacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Task?>> getTaskById(String taskId) async {
    try {
      final task = await localDataSource.getTaskById(taskId);
      return Result.success(task?.toEntity());
    } catch (e) {
      return Result.failure(Failure.cacheFailure(message: e.toString()));
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

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  bool _shouldShowOnDate(TaskModel task, DateTime date) {
    final scheduledDate = DateTime(
      task.scheduledAt.year,
      task.scheduledAt.month,
      task.scheduledAt.day,
    );

    final endDate = task.endDate == null
        ? null
        : DateTime(task.endDate!.year, task.endDate!.month, task.endDate!.day);

    if (date.isBefore(scheduledDate)) {
      return false;
    }

    // Carry forward unfinished tasks from any previous day to today.
    if (_shouldCarryForwardUnfinishedTask(
      task: task,
      scheduledDate: scheduledDate,
      date: date,
    )) {
      return true;
    }

    if (endDate != null && date.isAfter(endDate)) {
      return false;
    }

    // Show within [start, end] range when end date is provided.
    if (endDate != null) {
      return true;
    }

    if (_isSameDate(scheduledDate, date)) {
      return true;
    }

    return task.repeatsDaily && scheduledDate.isBefore(date);
  }

  bool _shouldCarryForwardUnfinishedTask({
    required TaskModel task,
    required DateTime scheduledDate,
    required DateTime date,
  }) {
    if (task.isCompleted) {
      return false;
    }
    final today = _toDateOnly(DateTime.now());
    if (!_isSameDate(date, today)) {
      return false;
    }
    return scheduledDate.isBefore(today);
  }

  bool _isLockedCompletedPastTask(Task task) {
    if (!task.isCompleted) {
      return false;
    }
    final today = _toDateOnly(DateTime.now());
    return _toDateOnly(task.scheduledAt).isBefore(today);
  }

  DateTime _toDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isEmoji(String value) {
    if (value.isEmpty) {
      return false;
    }
    return value.runes.any((rune) => rune > 127);
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
