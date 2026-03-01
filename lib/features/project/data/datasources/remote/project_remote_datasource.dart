import 'package:flutter/foundation.dart';
import 'package:logit/core/supabase/supabase_initializer.dart';
import 'package:logit/features/project/domain/entities/project.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectRemoteDataSource {
  static const String _projectsTable = 'projects';
  static const String _taskProjectsTable = 'task_projects';

  SupabaseClient? get _client {
    if (!SupabaseInitializer.isInitialized) {
      return null;
    }
    return Supabase.instance.client;
  }

  String? get currentUserId => _client?.auth.currentUser?.id;

  bool get canSync => currentUserId != null;

  Future<List<Project>> fetchProjects() async {
    final userId = currentUserId;
    final client = _client;
    _ensureRemoteAvailable(
      operation: 'fetchProjects',
      userId: userId,
      client: client,
    );

    try {
      final response = await client!
          .from(_projectsTable)
          .select()
          .eq('user_id', userId!)
          .order('name');

      return response
          .whereType<Map>()
          .map((row) => Project.fromJson(Map<String, dynamic>.from(row)))
          .toList(growable: false);
    } catch (error, stackTrace) {
      _logRemoteFailure(
        operation: 'fetchProjects',
        userId: userId,
        hasClient: client != null,
        error: error,
        stackTrace: stackTrace,
      );
      throw ProjectRemoteDataSourceException(
        operation: 'fetchProjects',
        message: 'Failed to fetch projects',
        userId: userId,
        hasClient: client != null,
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Map<String, String>> fetchTaskProjectMap() async {
    final userId = currentUserId;
    final client = _client;
    _ensureRemoteAvailable(
      operation: 'fetchTaskProjectMap',
      userId: userId,
      client: client,
    );

    try {
      final response = await client!
          .from(_taskProjectsTable)
          .select('task_id, project_id')
          .eq('user_id', userId!);

      final output = <String, String>{};
      for (final row in response.whereType<Map>()) {
        final map = Map<String, dynamic>.from(row);
        final taskId = (map['task_id'] ?? '').toString().trim();
        final projectId = (map['project_id'] ?? '').toString().trim();
        if (taskId.isEmpty || projectId.isEmpty) {
          continue;
        }
        output[taskId] = projectId;
      }
      return output;
    } catch (error, stackTrace) {
      _logRemoteFailure(
        operation: 'fetchTaskProjectMap',
        userId: userId,
        hasClient: client != null,
        error: error,
        stackTrace: stackTrace,
      );
      throw ProjectRemoteDataSourceException(
        operation: 'fetchTaskProjectMap',
        message: 'Failed to fetch task-project assignments',
        userId: userId,
        hasClient: client != null,
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> upsertProject(Project project) async {
    final userId = currentUserId;
    final client = _client;
    _ensureRemoteAvailable(
      operation: 'upsertProject',
      userId: userId,
      client: client,
    );

    try {
      await client!.from(_projectsTable).upsert({
        'id': project.id,
        'user_id': userId!,
        'name': project.name,
        'description': project.description,
        'created_at': project.createdAt.toIso8601String(),
        'updated_at': project.updatedAt.toIso8601String(),
      }, onConflict: 'user_id,id');
    } catch (error, stackTrace) {
      _logRemoteFailure(
        operation: 'upsertProject',
        userId: userId,
        hasClient: client != null,
        error: error,
        stackTrace: stackTrace,
      );
      throw ProjectRemoteDataSourceException(
        operation: 'upsertProject',
        message: 'Failed to upsert project ${project.id}',
        userId: userId,
        hasClient: client != null,
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> deleteProject(String projectId) async {
    final userId = currentUserId;
    final client = _client;
    _ensureRemoteAvailable(
      operation: 'deleteProject',
      userId: userId,
      client: client,
    );

    try {
      await client!.rpc(
        'delete_project_and_tasks',
        params: {'user_id': userId!, 'project_id': projectId},
      );
      return;
    } catch (error, stackTrace) {
      if (!_isMissingDeleteProjectRpc(error)) {
        _logRemoteFailure(
          operation: 'deleteProject',
          userId: userId,
          hasClient: client != null,
          error: error,
          stackTrace: stackTrace,
        );
        throw ProjectRemoteDataSourceException(
          operation: 'deleteProject',
          message: 'Failed to delete project $projectId',
          userId: userId,
          hasClient: client != null,
          cause: error,
          stackTrace: stackTrace,
        );
      }
      debugPrint(
        'ProjectRemoteDataSource.deleteProject RPC not found; '
        'falling back to sequential deletes with partial-failure risk.',
      );
    }

    try {
      // Fallback path when RPC is unavailable. This is not atomic: a failure
      // between the two statements can leave task-project rows removed while
      // the project row still exists.
      await client!
          .from(_taskProjectsTable)
          .delete()
          .eq('user_id', userId!)
          .eq('project_id', projectId);
      await client
          .from(_projectsTable)
          .delete()
          .eq('user_id', userId)
          .eq('id', projectId);
    } catch (error, stackTrace) {
      _logRemoteFailure(
        operation: 'deleteProject',
        userId: userId,
        hasClient: client != null,
        error: error,
        stackTrace: stackTrace,
      );
      throw ProjectRemoteDataSourceException(
        operation: 'deleteProject',
        message: 'Failed to delete project $projectId',
        userId: userId,
        hasClient: client != null,
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  bool _isMissingDeleteProjectRpc(Object error) {
    if (error is! PostgrestException) {
      return false;
    }
    final code = (error.code ?? '').toLowerCase();
    final message = [
      error.message,
      error.details,
      error.hint,
    ].whereType<String>().join(' ').toLowerCase();

    if (code == 'pgrst202') {
      return true;
    }
    return message.contains('delete_project_and_tasks') &&
        (message.contains('could not find') ||
            message.contains('does not exist'));
  }

  Future<void> assignTaskToProject({
    required String taskId,
    required String projectId,
  }) async {
    final userId = currentUserId;
    final client = _client;
    _ensureRemoteAvailable(
      operation: 'assignTaskToProject',
      userId: userId,
      client: client,
    );
    final now = DateTime.now().toIso8601String();
    try {
      await client!.from(_taskProjectsTable).upsert({
        'user_id': userId!,
        'task_id': taskId,
        'project_id': projectId,
        'updated_at': now,
      }, onConflict: 'user_id,task_id');
    } catch (error, stackTrace) {
      _logRemoteFailure(
        operation: 'assignTaskToProject',
        userId: userId,
        hasClient: client != null,
        error: error,
        stackTrace: stackTrace,
      );
      throw ProjectRemoteDataSourceException(
        operation: 'assignTaskToProject',
        message: 'Failed to assign task $taskId to project $projectId',
        userId: userId,
        hasClient: client != null,
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> removeTaskProject(String taskId) async {
    final userId = currentUserId;
    final client = _client;
    _ensureRemoteAvailable(
      operation: 'removeTaskProject',
      userId: userId,
      client: client,
    );
    try {
      await client!
          .from(_taskProjectsTable)
          .delete()
          .eq('user_id', userId!)
          .eq('task_id', taskId);
    } catch (error, stackTrace) {
      _logRemoteFailure(
        operation: 'removeTaskProject',
        userId: userId,
        hasClient: client != null,
        error: error,
        stackTrace: stackTrace,
      );
      throw ProjectRemoteDataSourceException(
        operation: 'removeTaskProject',
        message: 'Failed to remove task-project mapping for task $taskId',
        userId: userId,
        hasClient: client != null,
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _ensureRemoteAvailable({
    required String operation,
    required String? userId,
    required SupabaseClient? client,
  }) {
    if (client != null && userId != null && userId.trim().isNotEmpty) {
      return;
    }
    final message =
        'Remote unavailable for $operation (hasClient=${client != null}, userId="${userId ?? ''}")';
    debugPrint('ProjectRemoteDataSource warning: $message');
    throw ProjectRemoteDataSourceException(
      operation: operation,
      message: message,
      userId: userId,
      hasClient: client != null,
    );
  }

  void _logRemoteFailure({
    required String operation,
    required String? userId,
    required bool hasClient,
    required Object error,
    required StackTrace stackTrace,
  }) {
    debugPrint(
      'ProjectRemoteDataSource.$operation failed '
      '(hasClient=$hasClient, userId="${userId ?? ''}") '
      'error=$error\n$stackTrace',
    );
  }
}

class ProjectRemoteDataSourceException implements Exception {
  final String operation;
  final String message;
  final String? userId;
  final bool hasClient;
  final Object? cause;
  final StackTrace? stackTrace;

  const ProjectRemoteDataSourceException({
    required this.operation,
    required this.message,
    required this.userId,
    required this.hasClient,
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'ProjectRemoteDataSourceException('
        'operation: $operation, '
        'message: $message, '
        'userId: ${userId ?? ''}, '
        'hasClient: $hasClient, '
        'cause: $cause)';
  }
}
