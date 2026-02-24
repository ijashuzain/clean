import 'dart:convert';

import 'package:logit/core/failure/failure.dart';
import 'package:logit/features/task/data/datasources/local/task_local_datasource.dart';
import 'package:logit/features/task/data/datasources/remote/task_remote_datasource.dart';
import 'package:logit/features/task/data/models/task_model/task_model.dart';
import 'package:logit/features/task/data/repositories/task_repository_impl/task_repository_impl.dart';
import 'package:logit/features/task/domain/entities/task/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _InMemoryTaskLocalDataSource local;
  late _InMemoryTaskRemoteDataSource remote;
  late TaskRepositoryImpl repository;

  setUp(() {
    local = _InMemoryTaskLocalDataSource();
    remote = _InMemoryTaskRemoteDataSource();
    repository = TaskRepositoryImpl(
      localDataSource: local,
      remoteDataSource: remote,
    );
  });

  test('getAllTasks returns local tasks immediately', () async {
    final task = _taskEntity(
      id: 'task-local',
      scheduledAt: DateTime(2026, 2, 24, 9),
    );
    await local.upsertTask(TaskModel.fromEntity(task));

    final result = await repository.getAllTasks();

    result.when(
      success: (tasks) {
        expect(tasks, hasLength(1));
        expect(tasks.first.id, task.id);
      },
      failure: (_) => fail('Expected local-first success'),
    );
  });

  test(
    'upsertTask writes locally, queues sync, then flushes to remote',
    () async {
      final task = _taskEntity(
        id: 'task-upsert',
        scheduledAt: DateTime(2026, 2, 24, 10),
        reminders: [
          TaskReminder(
            id: 'rem-1',
            date: DateTime(2026, 2, 24),
            minuteOfDay: 9 * 60,
          ),
        ],
        subtasks: const [SubTask(id: 'sub-1', title: 'child')],
      );

      final result = await repository.upsertTask(task);

      result.when(
        success: (_) {},
        failure: (_) => fail('Expected successful local upsert'),
      );
      expect((await local.getTaskById(task.id))?.id, task.id);
      expect(local.pendingCount, 1);

      await _waitForCondition(
        () => local.pendingCount == 0,
        interval: const Duration(milliseconds: 20),
      );

      expect(remote.upsertCalls, contains(task.id));
      expect(remote.store[task.id]?.id, task.id);
    },
  );

  test(
    'deleteTask removes local record and flushes delete to remote',
    () async {
      final task = _taskEntity(
        id: 'task-delete',
        scheduledAt: DateTime(2026, 2, 24, 11),
      );
      final model = TaskModel.fromEntity(task);
      await local.upsertTask(model);
      remote.store[task.id] = model;

      final result = await repository.deleteTask(task.id);

      result.when(
        success: (_) {},
        failure: (_) => fail('Expected successful local delete'),
      );
      expect(await local.getTaskById(task.id), isNull);
      expect(local.pendingCount, 1);

      await _waitForCondition(
        () => local.pendingCount == 0,
        interval: const Duration(milliseconds: 20),
      );

      expect(remote.deleteCalls, contains(task.id));
      expect(remote.store.containsKey(task.id), isFalse);
    },
  );

  test('sync clears local data and queue when user changes', () async {
    final oldTask = TaskModel.fromEntity(
      _taskEntity(id: 'old-task', scheduledAt: DateTime(2026, 2, 20, 8)),
    );
    final remoteTask = TaskModel.fromEntity(
      _taskEntity(id: 'remote-task', scheduledAt: DateTime(2026, 2, 24, 12)),
    );

    await local.setSyncedUserId('old-user');
    await local.upsertTask(oldTask);
    await local.enqueueTaskUpsertForSync(oldTask);

    remote.userId = 'new-user';
    remote.store[remoteTask.id] = remoteTask;

    await repository.getAllTasks();

    await _waitForCondition(
      () => local.tasks.length == 1 && local.tasks.first.id == remoteTask.id,
      interval: const Duration(milliseconds: 20),
    );

    expect(await local.getSyncedUserId(), 'new-user');
    expect(local.pendingCount, 0);
    expect(local.tasks.first.id, 'remote-task');
    expect(local.tasks.first.id, isNot('old-task'));
  });

  test(
    'sync pull preserves local reminder fields while updating remote fields',
    () async {
      final localTask = TaskModel.fromEntity(
        _taskEntity(
          id: 'shared-id',
          title: 'Local title',
          scheduledAt: DateTime(2026, 2, 24, 9),
          reminders: [
            TaskReminder(
              id: 'local-rem-1',
              date: DateTime(2026, 2, 24),
              minuteOfDay: 7 * 60,
            ),
          ],
          reminderDate: DateTime(2026, 2, 24),
          reminderMinuteOfDay: 7 * 60,
        ),
      );
      final remoteTask = TaskModel.fromEntity(
        _taskEntity(
          id: 'shared-id',
          title: 'Remote title',
          scheduledAt: DateTime(2026, 2, 24, 9),
          reminders: const [],
          reminderDate: null,
          reminderMinuteOfDay: null,
        ),
      );

      await local.setSyncedUserId(remote.userId);
      await local.upsertTask(localTask);
      remote.store[remoteTask.id] = remoteTask;

      await repository.getAllTasks();

      await _waitForCondition(() {
        final merged = local.tasks.where((task) => task.id == remoteTask.id);
        return merged.isNotEmpty && merged.first.title == 'Remote title';
      }, interval: const Duration(milliseconds: 20));

      final merged = await local.getTaskById('shared-id');
      expect(merged, isNotNull);
      expect(merged!.title, 'Remote title');
      expect(merged.reminders, hasLength(1));
      expect(merged.reminders.first.id, 'local-rem-1');
      expect(merged.reminderDate, DateTime(2026, 2, 24));
      expect(merged.reminderMinuteOfDay, 7 * 60);
    },
  );

  test('toggleTaskCompletion blocks future tasks', () async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final futureTask = TaskModel.fromEntity(
      _taskEntity(id: 'future-task', scheduledAt: tomorrow),
    );
    await local.upsertTask(futureTask);

    final result = await repository.toggleTaskCompletion(
      taskId: futureTask.id,
      forDate: tomorrow,
    );

    result.when(
      success: (_) => fail('Expected failure for future task toggle'),
      failure: (failure) {
        expect(failure, isA<Failure>());
        expect(failure.message, 'Future tasks cannot be completed yet');
      },
    );
    expect((await local.getTaskById(futureTask.id))?.isCompleted, isFalse);
  });

  test(
    'upsert remains pending when remote upsert fails and syncs after recovery',
    () async {
      final task = _taskEntity(
        id: 'task-upsert-failure',
        scheduledAt: DateTime(2026, 2, 24, 13),
      );
      remote.failUpsert = true;

      final result = await repository.upsertTask(task);

      result.when(
        success: (_) {},
        failure: (_) => fail('Expected successful local upsert'),
      );

      await _waitForCondition(
        () => remote.upsertCalls.contains(task.id),
        interval: const Duration(milliseconds: 20),
      );
      expect(local.pendingCount, 1);
      expect(remote.store.containsKey(task.id), isFalse);

      remote.failUpsert = false;
      await repository.getAllTasks();

      await _waitForCondition(
        () => local.pendingCount == 0,
        interval: const Duration(milliseconds: 20),
      );
      expect(remote.store.containsKey(task.id), isTrue);
      expect(
        remote.upsertCalls.where((id) => id == task.id).length,
        greaterThanOrEqualTo(2),
      );
    },
  );

  test(
    'delete remains pending when remote delete fails and syncs after recovery',
    () async {
      final task = _taskEntity(
        id: 'task-delete-failure',
        scheduledAt: DateTime(2026, 2, 24, 14),
      );
      final model = TaskModel.fromEntity(task);
      await local.upsertTask(model);
      remote.store[task.id] = model;
      remote.failDelete = true;

      final result = await repository.deleteTask(task.id);

      result.when(
        success: (_) {},
        failure: (_) => fail('Expected successful local delete'),
      );

      await _waitForCondition(
        () => remote.deleteCalls.contains(task.id),
        interval: const Duration(milliseconds: 20),
      );
      expect(local.pendingCount, 1);
      expect(remote.store.containsKey(task.id), isTrue);

      remote.failDelete = false;
      await repository.getAllTasks();

      await _waitForCondition(
        () => local.pendingCount == 0,
        interval: const Duration(milliseconds: 20),
      );
      expect(remote.store.containsKey(task.id), isFalse);
      expect(
        remote.deleteCalls.where((id) => id == task.id).length,
        greaterThanOrEqualTo(2),
      );
    },
  );

  test(
    'fetch failure does not drop local tasks and sync recovers later',
    () async {
      final task = _taskEntity(
        id: 'task-fetch-failure',
        scheduledAt: DateTime(2026, 2, 24, 15),
      );
      final model = TaskModel.fromEntity(task);
      await local.upsertTask(model);
      remote.store[task.id] = model;
      remote.failFetch = true;

      final result = await repository.getAllTasks();

      result.when(
        success: (tasks) =>
            expect(tasks.any((item) => item.id == task.id), isTrue),
        failure: (_) => fail('Expected local-first success'),
      );

      await _waitForCondition(
        () => remote.fetchCalls > 0,
        interval: const Duration(milliseconds: 20),
      );
      expect((await local.getTaskById(task.id))?.id, task.id);

      remote.failFetch = false;
      await repository.getAllTasks();

      await _waitForCondition(
        () => remote.fetchCalls > 1,
        interval: const Duration(milliseconds: 20),
      );
      expect((await local.getTaskById(task.id))?.id, task.id);
    },
  );

  test(
    'sync is skipped while canSync is false and resumes when enabled',
    () async {
      final task = _taskEntity(
        id: 'task-sync-disabled',
        scheduledAt: DateTime(2026, 2, 24, 16),
      );
      remote.canSyncValue = false;

      final result = await repository.upsertTask(task);

      result.when(
        success: (_) {},
        failure: (_) => fail('Expected successful local upsert'),
      );

      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(local.pendingCount, 1);
      expect(remote.upsertCalls, isEmpty);
      expect(remote.fetchCalls, 0);
      expect(remote.store.containsKey(task.id), isFalse);

      remote.canSyncValue = true;
      await repository.getAllTasks();

      await _waitForCondition(
        () => local.pendingCount == 0,
        interval: const Duration(milliseconds: 20),
      );
      expect(remote.store.containsKey(task.id), isTrue);
    },
  );
}

class _InMemoryTaskLocalDataSource implements TaskLocalDataSource {
  final List<TaskModel> _tasks = <TaskModel>[];
  final List<Map<String, dynamic>> _pending = <Map<String, dynamic>>[];
  int _operationSeq = 0;
  String? _syncedUserId;

  int get pendingCount => _pending.length;

  List<TaskModel> get tasks => _tasks.map(_cloneTask).toList(growable: false);

  @override
  Future<void> clearPendingSyncOperations() async {
    _pending.clear();
  }

  @override
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
  }

  @override
  Future<void> enqueueTaskDeleteForSync(String taskId) async {
    _pending.removeWhere((item) => item['taskId'] == taskId);
    _pending.add({
      'id': 'op_${_operationSeq++}',
      'type': 'delete',
      'taskId': taskId,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> enqueueTaskUpsertForSync(TaskModel task) async {
    _pending.removeWhere((item) => item['taskId'] == task.id);
    _pending.add({
      'id': 'op_${_operationSeq++}',
      'type': 'upsert',
      'taskId': task.id,
      'task': _toSerializableMap(task.toJson()),
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingSyncOperations() async {
    return _pending.map(_cloneMap).toList(growable: true);
  }

  @override
  Future<TaskModel?> getTaskById(String taskId) async {
    for (final task in _tasks) {
      if (task.id == taskId) {
        return _cloneTask(task);
      }
    }
    return null;
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    final copy = _tasks.map(_cloneTask).toList(growable: false);
    copy.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return copy;
  }

  @override
  Future<String?> getSyncedUserId() async => _syncedUserId;

  @override
  Future<void> removePendingSyncOperation(String operationId) async {
    _pending.removeWhere((item) => item['id'] == operationId);
  }

  @override
  Future<void> replaceAllTasks(List<TaskModel> tasks) async {
    _tasks
      ..clear()
      ..addAll(tasks.map(_cloneTask));
  }

  @override
  Future<void> setSyncedUserId(String? userId) async {
    _syncedUserId = userId;
  }

  @override
  Future<void> upsertTask(TaskModel task) async {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index == -1) {
      _tasks.add(_cloneTask(task));
      return;
    }
    _tasks[index] = _cloneTask(task);
  }

  TaskModel _cloneTask(TaskModel task) {
    return TaskModel.fromJson(_toSerializableMap(task.toJson()));
  }

  Map<String, dynamic> _cloneMap(Map<String, dynamic> source) {
    return _toSerializableMap(source);
  }

  Map<String, dynamic> _toSerializableMap(Map<String, dynamic> source) {
    return Map<String, dynamic>.from(
      jsonDecode(jsonEncode(source)) as Map<String, dynamic>,
    );
  }
}

class _InMemoryTaskRemoteDataSource implements TaskRemoteDataSource {
  bool canSyncValue = true;
  String? userId = 'user-1';
  bool failFetch = false;
  bool failUpsert = false;
  bool failDelete = false;

  int fetchCalls = 0;
  final List<String> upsertCalls = <String>[];
  final List<String> deleteCalls = <String>[];
  final Map<String, TaskModel> store = <String, TaskModel>{};

  @override
  bool get canSync => canSyncValue;

  @override
  String? get currentUserId => userId;

  @override
  Future<void> deleteTask(String taskId) async {
    deleteCalls.add(taskId);
    if (failDelete) {
      throw Exception('delete failed');
    }
    store.remove(taskId);
  }

  @override
  Future<List<TaskModel>> fetchTasks() async {
    fetchCalls++;
    if (failFetch) {
      throw Exception('fetch failed');
    }
    return store.values.map((task) => _cloneTask(task)).toList(growable: false)
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  @override
  Future<void> syncPendingChanges() async {}

  @override
  Future<void> upsertTask(TaskModel task) async {
    upsertCalls.add(task.id);
    if (failUpsert) {
      throw Exception('upsert failed');
    }
    store[task.id] = _cloneTask(task);
  }

  TaskModel _cloneTask(TaskModel task) {
    final serializableMap = Map<String, dynamic>.from(
      jsonDecode(jsonEncode(task.toJson())) as Map<String, dynamic>,
    );
    return TaskModel.fromJson(serializableMap);
  }
}

Task _taskEntity({
  required String id,
  required DateTime scheduledAt,
  String title = 'Task',
  List<TaskReminder> reminders = const <TaskReminder>[],
  List<SubTask> subtasks = const <SubTask>[],
  DateTime? reminderDate,
  int? reminderMinuteOfDay,
}) {
  final createdAt = DateTime(2026, 2, 24, 8, 0);
  return Task(
    id: id,
    title: title,
    topic: 'Topic',
    note: 'Note',
    iconKey: '✅',
    scheduledAt: scheduledAt,
    reminders: reminders,
    reminderDate: reminderDate,
    reminderMinuteOfDay: reminderMinuteOfDay,
    subtasks: subtasks,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

Future<void> _waitForCondition(
  bool Function() condition, {
  int maxAttempts = 200,
  Duration interval = const Duration(milliseconds: 2),
}) async {
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    if (condition()) {
      return;
    }
    await Future<void>.delayed(interval);
  }
  fail('Timed out waiting for async condition');
}
