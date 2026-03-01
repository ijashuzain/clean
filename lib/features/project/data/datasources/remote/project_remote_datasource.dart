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
    if (userId == null || client == null) {
      return const <Project>[];
    }

    final response = await client
        .from(_projectsTable)
        .select()
        .eq('user_id', userId)
        .order('name');

    return response
        .whereType<Map>()
        .map((row) => Project.fromJson(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Future<Map<String, String>> fetchTaskProjectMap() async {
    final userId = currentUserId;
    final client = _client;
    if (userId == null || client == null) {
      return const <String, String>{};
    }

    final response = await client
        .from(_taskProjectsTable)
        .select('task_id, project_id')
        .eq('user_id', userId);

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
  }

  Future<void> upsertProject(Project project) async {
    final userId = currentUserId;
    final client = _client;
    if (userId == null || client == null) {
      return;
    }

    await client.from(_projectsTable).upsert({
      'id': project.id,
      'user_id': userId,
      'name': project.name,
      'description': project.description,
      'created_at': project.createdAt.toIso8601String(),
      'updated_at': project.updatedAt.toIso8601String(),
    }, onConflict: 'user_id,id');
  }

  Future<void> deleteProject(String projectId) async {
    final userId = currentUserId;
    final client = _client;
    if (userId == null || client == null) {
      return;
    }

    await client
        .from(_taskProjectsTable)
        .delete()
        .eq('user_id', userId)
        .eq('project_id', projectId);
    await client
        .from(_projectsTable)
        .delete()
        .eq('user_id', userId)
        .eq('id', projectId);
  }

  Future<void> assignTaskToProject({
    required String taskId,
    required String projectId,
  }) async {
    final userId = currentUserId;
    final client = _client;
    if (userId == null || client == null) {
      return;
    }
    final now = DateTime.now().toIso8601String();
    await client.from(_taskProjectsTable).upsert({
      'user_id': userId,
      'task_id': taskId,
      'project_id': projectId,
      'updated_at': now,
    }, onConflict: 'user_id,task_id');
  }

  Future<void> removeTaskProject(String taskId) async {
    final userId = currentUserId;
    final client = _client;
    if (userId == null || client == null) {
      return;
    }
    await client
        .from(_taskProjectsTable)
        .delete()
        .eq('user_id', userId)
        .eq('task_id', taskId);
  }
}
