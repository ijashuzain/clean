import 'dart:convert';

import 'package:logit/core/supabase/supabase_initializer.dart';
import 'package:logit/features/task/data/models/task_model/task_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'task_remote_datasource.g.dart';

@riverpod
TaskRemoteDataSource taskRemoteDataSource(Ref ref) {
  return TaskRemoteDataSourceImpl();
}

abstract class TaskRemoteDataSource {
  bool get canSync;
  String? get currentUserId;
  Future<List<TaskModel>> fetchTasks();
  Future<void> upsertTask(TaskModel task);
  Future<void> deleteTask(String taskId);
  Future<void> syncPendingChanges();
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  static const String _table = 'tasks';

  SupabaseClient? get _client {
    if (!SupabaseInitializer.isInitialized) {
      return null;
    }
    return Supabase.instance.client;
  }

  @override
  bool get canSync => currentUserId != null;

  @override
  String? get currentUserId => _client?.auth.currentUser?.id;

  @override
  Future<List<TaskModel>> fetchTasks() async {
    final userId = currentUserId;
    final client = _client;
    if (userId == null || client == null) {
      return const <TaskModel>[];
    }

    final response = await client.from(_table).select().eq('user_id', userId);
    final tasks = response
        .whereType<Map>()
        .map((row) => _toTaskModel(Map<String, dynamic>.from(row)))
        .toList(growable: false);

    tasks.sort(
      (first, second) => first.scheduledAt.compareTo(second.scheduledAt),
    );
    return tasks;
  }

  @override
  Future<void> upsertTask(TaskModel task) async {
    final userId = currentUserId;
    final client = _client;
    if (userId == null || client == null) {
      return;
    }

    await client
        .from(_table)
        .upsert(
          _toRemotePayload(task: task, userId: userId),
          onConflict: 'user_id,id',
        );
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final userId = currentUserId;
    final client = _client;
    if (userId == null || client == null) {
      return;
    }

    await client.from(_table).delete().eq('user_id', userId).eq('id', taskId);
  }

  @override
  Future<void> syncPendingChanges() async {
    // Current sync is immediate for each CRUD operation.
  }

  TaskModel _toTaskModel(Map<String, dynamic> row) {
    final nowIso = DateTime.now().toIso8601String();
    return TaskModel.fromJson({
      'id': (row['id'] ?? '').toString(),
      'title': (row['title'] ?? '').toString(),
      'topic': (row['topic'] ?? '').toString(),
      'note': (row['note'] ?? '').toString(),
      'iconKey': (row['icon_key'] ?? '').toString(),
      'scheduledAt': row['scheduled_at'] ?? nowIso,
      'endDate': row['end_date'],
      'startMinuteOfDay': row['start_minute_of_day'] as int?,
      'endMinuteOfDay': row['end_minute_of_day'] as int?,
      'reminders': _normalizeModelList(row['reminders']),
      'reminderDate': row['reminder_date'],
      'reminderMinuteOfDay': row['reminder_minute_of_day'] as int?,
      'repeatsDaily': row['repeats_daily'] as bool? ?? false,
      'isCompleted': row['is_completed'] as bool? ?? false,
      'subtasks': _normalizeModelList(row['subtasks']),
      'createdAt': row['created_at'] ?? nowIso,
      'updatedAt': row['updated_at'] ?? nowIso,
    });
  }

  Map<String, dynamic> _toRemotePayload({
    required TaskModel task,
    required String userId,
  }) {
    final json = _toSerializableMap(task);
    return {
      'id': task.id,
      'user_id': userId,
      'title': task.title,
      'topic': task.topic,
      'note': task.note,
      'icon_key': task.iconKey,
      'scheduled_at': task.scheduledAt.toIso8601String(),
      'end_date': task.endDate?.toIso8601String(),
      'start_minute_of_day': task.startMinuteOfDay,
      'end_minute_of_day': task.endMinuteOfDay,
      'reminders': _normalizeModelList(json['reminders']),
      'reminder_date': task.reminderDate?.toIso8601String(),
      'reminder_minute_of_day': task.reminderMinuteOfDay,
      'repeats_daily': task.repeatsDaily,
      'is_completed': task.isCompleted,
      'subtasks': _normalizeModelList(json['subtasks']),
      'created_at': task.createdAt.toIso8601String(),
      'updated_at': task.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _toSerializableMap(TaskModel task) {
    return Map<String, dynamic>.from(
      jsonDecode(jsonEncode(task.toJson())) as Map<String, dynamic>,
    );
  }

  List<Map<String, dynamic>> _normalizeModelList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }

    if (value is Map) {
      return value.values
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }

    return const <Map<String, dynamic>>[];
  }
}
