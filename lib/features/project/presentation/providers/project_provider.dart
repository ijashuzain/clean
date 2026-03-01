import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logit/core/utils/status/status.dart';
import 'package:logit/features/auth/presentation/providers/auth_session_provider/auth_session_provider.dart';
import 'package:logit/features/project/data/datasources/local/project_local_datasource.dart';
import 'package:logit/features/project/data/datasources/remote/project_remote_datasource.dart';
import 'package:logit/features/project/domain/entities/project.dart';
import 'package:logit/features/task/domain/entities/task/task.dart';

@immutable
class ProjectState {
  final bool isReady;
  final bool isSyncing;
  final List<Project> projects;
  final Map<String, String> taskProjectMap;
  final Status actionStatus;

  const ProjectState({
    this.isReady = false,
    this.isSyncing = false,
    this.projects = const <Project>[],
    this.taskProjectMap = const <String, String>{},
    this.actionStatus = const Status.initial(),
  });

  ProjectState copyWith({
    bool? isReady,
    bool? isSyncing,
    List<Project>? projects,
    Map<String, String>? taskProjectMap,
    Status? actionStatus,
  }) {
    return ProjectState(
      isReady: isReady ?? this.isReady,
      isSyncing: isSyncing ?? this.isSyncing,
      projects: projects ?? this.projects,
      taskProjectMap: taskProjectMap ?? this.taskProjectMap,
      actionStatus: actionStatus ?? this.actionStatus,
    );
  }
}

final projectNotifierProvider =
    StateNotifierProvider<ProjectNotifier, ProjectState>((ref) {
      final notifier = ProjectNotifier(ref);
      ref.listen(authSessionNotifierProvider, (previous, next) {
        final previousUserId = previous?.user.id.trim() ?? '';
        final nextUserId = next.user.id.trim();
        if (previousUserId != nextUserId) {
          unawaited(notifier.handleUserScopeChanged(nextUserId));
        }
      });
      return notifier;
    });

class ProjectNotifier extends StateNotifier<ProjectState> {
  static const String _dailyOccurrenceSeparator = '__occ__';

  final Ref _ref;
  final ProjectLocalDataSource _localDataSource = ProjectLocalDataSource();
  final ProjectRemoteDataSource _remoteDataSource = ProjectRemoteDataSource();

  ProjectNotifier(this._ref) : super(const ProjectState()) {
    Future.microtask(_initialize);
  }

  Future<void> _initialize() async {
    final snapshot = await _localDataSource.readSnapshot();
    state = state.copyWith(
      isReady: true,
      projects: snapshot.projects,
      taskProjectMap: snapshot.taskProjectMap,
    );
    await handleUserScopeChanged(
      _currentUserId,
      initialSyncedUserId: snapshot.syncedUserId,
    );
  }

  String get _currentUserId {
    return _ref.read(authSessionNotifierProvider).user.id.trim();
  }

  Future<void> handleUserScopeChanged(
    String userId, {
    String? initialSyncedUserId,
  }) async {
    final normalizedUserId = userId.trim();
    final syncedUserId =
        initialSyncedUserId ??
        (await _localDataSource.readSnapshot()).syncedUserId;

    if (syncedUserId != null && syncedUserId != normalizedUserId) {
      await _localDataSource.clearAll();
      state = state.copyWith(
        projects: const <Project>[],
        taskProjectMap: const <String, String>{},
      );
    }

    if (normalizedUserId.isEmpty) {
      await _localDataSource.writeSyncedUserId(null);
      return;
    }

    await _localDataSource.writeSyncedUserId(normalizedUserId);
    await syncFromRemote();
  }

  Future<void> syncFromRemote() async {
    if (!_remoteDataSource.canSync || _currentUserId.isEmpty) {
      return;
    }
    state = state.copyWith(isSyncing: true);
    try {
      final projects = await _remoteDataSource.fetchProjects();
      final taskProjectMap = await _remoteDataSource.fetchTaskProjectMap();
      await _localDataSource.writeProjects(projects);
      await _localDataSource.writeTaskProjectMap(taskProjectMap);
      state = state.copyWith(
        projects: projects,
        taskProjectMap: taskProjectMap,
        actionStatus: const Status.success(),
      );
    } catch (error) {
      state = state.copyWith(actionStatus: Status.failure(error.toString()));
      debugPrint('Project sync error: $error');
    } finally {
      state = state.copyWith(isSyncing: false);
    }
  }

  Future<void> createProject({
    required String name,
    String description = '',
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      state = state.copyWith(
        actionStatus: const Status.failure('Project name is required'),
      );
      return;
    }
    final now = DateTime.now();
    final project = Project(
      id: now.microsecondsSinceEpoch.toString(),
      name: trimmedName,
      description: description.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _upsertLocalProject(project);
    unawaited(_upsertRemoteProject(project));
  }

  Future<void> updateProject({
    required String projectId,
    required String name,
    String? description,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      state = state.copyWith(
        actionStatus: const Status.failure('Project name is required'),
      );
      return;
    }

    Project? existing;
    for (final item in state.projects) {
      if (item.id == projectId) {
        existing = item;
        break;
      }
    }
    if (existing == null) {
      state = state.copyWith(
        actionStatus: const Status.failure('Project not found'),
      );
      return;
    }

    final updated = existing.copyWith(
      name: trimmedName,
      description: description?.trim() ?? existing.description,
      updatedAt: DateTime.now(),
    );
    await _upsertLocalProject(updated);
    unawaited(_upsertRemoteProject(updated));
  }

  Future<void> deleteProject(String projectId) async {
    final updatedProjects = state.projects
        .where((project) => project.id != projectId)
        .toList(growable: false);
    final updatedMap = Map<String, String>.from(state.taskProjectMap)
      ..removeWhere(
        (taskId, assignedProjectId) => assignedProjectId == projectId,
      );

    await _localDataSource.writeProjects(updatedProjects);
    await _localDataSource.writeTaskProjectMap(updatedMap);
    state = state.copyWith(
      projects: updatedProjects,
      taskProjectMap: updatedMap,
      actionStatus: const Status.success(),
    );

    unawaited(_deleteRemoteProject(projectId));
  }

  Future<void> assignTaskToProject({
    required String taskId,
    String? projectId,
  }) async {
    final normalizedTaskId = taskId.trim();
    final normalizedProjectId = projectId?.trim();
    if (normalizedTaskId.isEmpty) {
      return;
    }

    final updatedMap = Map<String, String>.from(state.taskProjectMap);
    if (normalizedProjectId == null || normalizedProjectId.isEmpty) {
      updatedMap.remove(normalizedTaskId);
    } else {
      updatedMap[normalizedTaskId] = normalizedProjectId;
    }
    await _localDataSource.writeTaskProjectMap(updatedMap);
    state = state.copyWith(
      taskProjectMap: updatedMap,
      actionStatus: const Status.success(),
    );

    if (normalizedProjectId == null || normalizedProjectId.isEmpty) {
      unawaited(_removeRemoteTaskProject(normalizedTaskId));
      return;
    }
    unawaited(
      _assignRemoteTaskProject(
        taskId: normalizedTaskId,
        projectId: normalizedProjectId,
      ),
    );
  }

  Project? projectById(String projectId) {
    final normalized = projectId.trim();
    if (normalized.isEmpty) {
      return null;
    }
    for (final project in state.projects) {
      if (project.id == normalized) {
        return project;
      }
    }
    return null;
  }

  List<Task> tasksForProject({
    required List<Task> tasks,
    required String projectId,
  }) {
    final normalized = projectId.trim();
    if (normalized.isEmpty) {
      return const <Task>[];
    }
    return tasks.where((task) {
      final taskProjectId = projectIdForTaskId(task.id);
      return taskProjectId == normalized;
    }).toList(growable: false);
  }

  String displayTopicForTask(Task task) {
    final projectId = projectIdForTaskId(task.id);
    final topic = task.topic.trim();
    if (projectId == null || projectId.isEmpty) {
      return topic;
    }
    final project = projectById(projectId);
    if (project == null) {
      return topic;
    }
    if (topic.isEmpty) {
      return project.name;
    }
    return '${project.name} - $topic';
  }

  String? projectIdForTaskId(String taskId) {
    final normalizedTaskId = taskId.trim();
    if (normalizedTaskId.isEmpty) {
      return null;
    }

    final directProjectId = state.taskProjectMap[normalizedTaskId];
    if (directProjectId != null && directProjectId.trim().isNotEmpty) {
      return directProjectId.trim();
    }

    final sourceTaskId = _sourceTaskIdFromOccurrenceId(normalizedTaskId);
    if (sourceTaskId == null) {
      return null;
    }
    final sourceProjectId = state.taskProjectMap[sourceTaskId];
    if (sourceProjectId == null || sourceProjectId.trim().isEmpty) {
      return null;
    }
    return sourceProjectId.trim();
  }

  Future<void> _upsertLocalProject(Project project) async {
    final projects = state.projects.toList(growable: true);
    final index = projects.indexWhere((item) => item.id == project.id);
    if (index == -1) {
      projects.add(project);
    } else {
      projects[index] = project;
    }
    projects.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    final immutableProjects = projects.toList(growable: false);
    await _localDataSource.writeProjects(immutableProjects);
    state = state.copyWith(
      projects: immutableProjects,
      actionStatus: const Status.success(),
    );
  }

  Future<void> _upsertRemoteProject(Project project) async {
    try {
      await _remoteDataSource.upsertProject(project);
    } catch (error) {
      state = state.copyWith(actionStatus: Status.failure(error.toString()));
      debugPrint('Project upsert sync error: $error');
    }
  }

  Future<void> _deleteRemoteProject(String projectId) async {
    try {
      await _remoteDataSource.deleteProject(projectId);
    } catch (error) {
      state = state.copyWith(actionStatus: Status.failure(error.toString()));
      debugPrint('Project delete sync error: $error');
    }
  }

  Future<void> _assignRemoteTaskProject({
    required String taskId,
    required String projectId,
  }) async {
    try {
      await _remoteDataSource.assignTaskToProject(
        taskId: taskId,
        projectId: projectId,
      );
    } catch (error) {
      state = state.copyWith(actionStatus: Status.failure(error.toString()));
      debugPrint('Project task assignment sync error: $error');
    }
  }

  Future<void> _removeRemoteTaskProject(String taskId) async {
    try {
      await _remoteDataSource.removeTaskProject(taskId);
    } catch (error) {
      state = state.copyWith(actionStatus: Status.failure(error.toString()));
      debugPrint('Project task unassign sync error: $error');
    }
  }

  String? _sourceTaskIdFromOccurrenceId(String taskId) {
    final separatorIndex = taskId.lastIndexOf(_dailyOccurrenceSeparator);
    if (separatorIndex <= 0) {
      return null;
    }
    return taskId.substring(0, separatorIndex);
  }
}
