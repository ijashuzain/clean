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
  Future<void> deleteTask(String taskId);
  Future<TaskModel?> getTaskById(String taskId);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Box<dynamic> _box = Hive.box<dynamic>(HiveBoxNames.task);

  @override
  Future<List<TaskModel>> getTasks() async {
    final rawTasks =
        _box.get(HiveTaskKeys.tasks, defaultValue: <dynamic>[])
            as List<dynamic>;
    return rawTasks
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(TaskModel.fromJson)
        .toList(growable: false)
      ..sort(
        (first, second) => first.scheduledAt.compareTo(second.scheduledAt),
      );
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

  Map<String, dynamic> _toStorageMap(TaskModel model) {
    // Ensure nested models are converted into plain JSON maps/lists.
    return Map<String, dynamic>.from(
      jsonDecode(jsonEncode(model.toJson())) as Map<String, dynamic>,
    );
  }
}
