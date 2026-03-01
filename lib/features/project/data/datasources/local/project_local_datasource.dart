import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:logit/core/constants/hive_keys.dart';
import 'package:logit/features/project/domain/entities/project.dart';

class ProjectLocalSnapshot {
  final List<Project> projects;
  final Map<String, String> taskProjectMap;
  final String? syncedUserId;

  const ProjectLocalSnapshot({
    required this.projects,
    required this.taskProjectMap,
    required this.syncedUserId,
  });
}

class ProjectLocalDataSource {
  final Box<dynamic> _box = Hive.box<dynamic>(HiveBoxNames.project);

  Future<ProjectLocalSnapshot> readSnapshot() async {
    final rawProjects =
        _box.get(HiveProjectKeys.projects, defaultValue: <dynamic>[])
            as List<dynamic>;
    final projects = <Project>[];
    for (final item in rawProjects) {
      if (item is! Map) {
        continue;
      }
      try {
        projects.add(
          Project.fromJson(_normalizeMap(Map<dynamic, dynamic>.from(item))),
        );
      } catch (_) {
        // Ignore malformed legacy project payloads.
      }
    }

    projects.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    final rawTaskProjectMap =
        _box.get(
              HiveProjectKeys.taskProjectMap,
              defaultValue: <dynamic, dynamic>{},
            )
            as Map<dynamic, dynamic>;
    final taskProjectMap = <String, String>{};
    for (final entry in rawTaskProjectMap.entries) {
      final taskId = entry.key.toString().trim();
      final projectId = entry.value.toString().trim();
      if (taskId.isEmpty || projectId.isEmpty) {
        continue;
      }
      taskProjectMap[taskId] = projectId;
    }

    final syncedUserId = _box.get(HiveProjectKeys.syncedUserId) as String?;
    final normalizedSyncedUserId =
        syncedUserId == null || syncedUserId.trim().isEmpty
        ? null
        : syncedUserId.trim();

    return ProjectLocalSnapshot(
      projects: projects.toList(growable: false),
      taskProjectMap: Map<String, String>.from(taskProjectMap),
      syncedUserId: normalizedSyncedUserId,
    );
  }

  Future<void> writeProjects(List<Project> projects) async {
    final serialized = projects.map(
      (project) => _toStorageMap(project.toJson()),
    );
    await _box.put(
      HiveProjectKeys.projects,
      serialized.toList(growable: false),
    );
  }

  Future<void> writeTaskProjectMap(Map<String, String> taskProjectMap) async {
    await _box.put(
      HiveProjectKeys.taskProjectMap,
      Map<String, String>.from(taskProjectMap),
    );
  }

  Future<void> writeSyncedUserId(String? userId) async {
    final normalized = userId?.trim() ?? '';
    if (normalized.isEmpty) {
      await _box.delete(HiveProjectKeys.syncedUserId);
      return;
    }
    await _box.put(HiveProjectKeys.syncedUserId, normalized);
  }

  Future<void> clearAll() async {
    await _box.delete(HiveProjectKeys.projects);
    await _box.delete(HiveProjectKeys.taskProjectMap);
    await _box.delete(HiveProjectKeys.syncedUserId);
  }

  Map<String, dynamic> _toStorageMap(Map<String, dynamic> source) {
    return Map<String, dynamic>.from(
      jsonDecode(jsonEncode(source)) as Map<String, dynamic>,
    );
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
