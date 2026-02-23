import 'package:logit/core/constants/hive_keys.dart';
import 'package:logit/features/task/data/models/task_model/task_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:convert';

part 'task_local_datasource.g.dart';

@riverpod
TaskLocalDataSource taskLocalDataSource(Ref ref) {
  return TaskLocalDataSourceImpl();
}

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> upsertTask(TaskModel task);
  Future<void> replaceAllTasks(List<TaskModel> tasks);
  Future<void> deleteTask(String taskId);
  Future<TaskModel?> getTaskById(String taskId);
  Future<String?> getSyncedUserId();
  Future<void> setSyncedUserId(String? userId);
  Future<void> enqueueTaskUpsertForSync(TaskModel task);
  Future<void> enqueueTaskDeleteForSync(String taskId);
  Future<List<Map<String, dynamic>>> getPendingSyncOperations();
  Future<void> removePendingSyncOperation(String operationId);
  Future<void> clearPendingSyncOperations();
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Box<dynamic> _box = Hive.box<dynamic>(HiveBoxNames.task);

  @override
  Future<List<TaskModel>> getTasks() async {
    final rawTasks =
        _box.get(HiveTaskKeys.tasks, defaultValue: <dynamic>[])
            as List<dynamic>;
    final parsedTasks = <TaskModel>[];

    for (final rawTask in rawTasks) {
      if (rawTask is! Map) {
        continue;
      }

      try {
        parsedTasks.add(TaskModel.fromJson(_normalizeTaskMap(rawTask)));
      } catch (_) {
        // Skip invalid/legacy payloads instead of crashing the whole timeline.
      }
    }

    parsedTasks.sort(
      (first, second) => first.scheduledAt.compareTo(second.scheduledAt),
    );
    return parsedTasks.toList(growable: false);
  }

  @override
  Future<void> upsertTask(TaskModel task) async {
    final allTasks = (await getTasks()).toList();
    final index = allTasks.indexWhere((item) => item.id == task.id);
    if (index == -1) {
      allTasks.add(task);
    } else {
      allTasks[index] = task;
    }

    await _box.put(
      HiveTaskKeys.tasks,
      allTasks.map(_toStorageMap).toList(growable: false),
    );
  }

  @override
  Future<void> replaceAllTasks(List<TaskModel> tasks) async {
    await _box.put(
      HiveTaskKeys.tasks,
      tasks.map(_toStorageMap).toList(growable: false),
    );
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final allTasks = await getTasks();
    final updated = allTasks
        .where((task) => task.id != taskId)
        .toList(growable: false);
    await _box.put(
      HiveTaskKeys.tasks,
      updated.map(_toStorageMap).toList(growable: false),
    );
  }

  @override
  Future<TaskModel?> getTaskById(String taskId) async {
    final allTasks = await getTasks();
    for (final task in allTasks) {
      if (task.id == taskId) {
        return task;
      }
    }
    return null;
  }

  @override
  Future<String?> getSyncedUserId() async {
    final value = _box.get(HiveTaskKeys.syncedUserId) as String?;
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value;
  }

  @override
  Future<void> setSyncedUserId(String? userId) async {
    final normalized = userId?.trim() ?? '';
    if (normalized.isEmpty) {
      await _box.delete(HiveTaskKeys.syncedUserId);
      return;
    }
    await _box.put(HiveTaskKeys.syncedUserId, normalized);
  }

  @override
  Future<void> enqueueTaskUpsertForSync(TaskModel task) async {
    final operations = await getPendingSyncOperations();
    operations.removeWhere((item) => item['taskId'] == task.id);
    operations.add({
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'type': 'upsert',
      'taskId': task.id,
      'task': _toStorageMap(task),
      'createdAt': DateTime.now().toIso8601String(),
    });
    await _box.put(HiveTaskKeys.pendingSyncOperations, operations);
  }

  @override
  Future<void> enqueueTaskDeleteForSync(String taskId) async {
    final normalizedTaskId = taskId.trim();
    if (normalizedTaskId.isEmpty) {
      return;
    }
    final operations = await getPendingSyncOperations();
    operations.removeWhere((item) => item['taskId'] == normalizedTaskId);
    operations.add({
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'type': 'delete',
      'taskId': normalizedTaskId,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await _box.put(HiveTaskKeys.pendingSyncOperations, operations);
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingSyncOperations() async {
    final raw =
        (_box.get(HiveTaskKeys.pendingSyncOperations, defaultValue: <dynamic>[])
            as List<dynamic>);

    return raw
        .whereType<Map>()
        .map((item) => _normalizeMap(Map<dynamic, dynamic>.from(item)))
        .toList(growable: true);
  }

  @override
  Future<void> removePendingSyncOperation(String operationId) async {
    final normalizedId = operationId.trim();
    if (normalizedId.isEmpty) {
      return;
    }
    final operations = await getPendingSyncOperations();
    operations.removeWhere((item) => item['id'] == normalizedId);
    await _box.put(HiveTaskKeys.pendingSyncOperations, operations);
  }

  @override
  Future<void> clearPendingSyncOperations() async {
    await _box.delete(HiveTaskKeys.pendingSyncOperations);
  }

  Map<String, dynamic> _toStorageMap(TaskModel model) {
    // Ensure nested models are converted into plain JSON maps/lists.
    return Map<String, dynamic>.from(
      jsonDecode(jsonEncode(model.toJson())) as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> _normalizeTaskMap(Map source) {
    final normalized = _normalizeMap(Map<dynamic, dynamic>.from(source));

    normalized['reminders'] = _normalizeModelList(normalized['reminders']);
    normalized['subtasks'] = _normalizeModelList(normalized['subtasks']);

    return normalized;
  }

  List<Map<String, dynamic>> _normalizeModelList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => _normalizeMap(Map<dynamic, dynamic>.from(item)))
          .toList(growable: false);
    }

    if (value is Map) {
      return value.values
          .whereType<Map>()
          .map((item) => _normalizeMap(Map<dynamic, dynamic>.from(item)))
          .toList(growable: false);
    }

    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _normalizeMap(Map<dynamic, dynamic> source) {
    return source.map<String, dynamic>(
      (key, value) =>
          MapEntry<String, dynamic>(key.toString(), _normalizeValue(value)),
    );
  }

  dynamic _normalizeValue(dynamic value) {
    if (value is Map) {
      return _normalizeMap(Map<dynamic, dynamic>.from(value));
    }
    if (value is List) {
      return value.map(_normalizeValue).toList(growable: false);
    }
    return value;
  }
}
