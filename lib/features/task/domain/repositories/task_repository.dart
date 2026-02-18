import 'package:logit/core/utils/result/result.dart';
import 'package:logit/features/task/domain/entities/task/task.dart';

abstract class TaskRepository {
  Future<Result<List<Task>>> getAllTasks();
  Future<Result<List<Task>>> getTasksByDate(DateTime date);
  Future<Result<Map<String, List<String>>>> getEmojiPreviewForRange({
    required DateTime from,
    required DateTime to,
  });
  Future<Result<void>> upsertTask(Task task);
  Future<Result<void>> toggleTaskCompletion({
    required String taskId,
    String? subTaskId,
  });
  Future<Result<void>> deleteTask(String taskId);
  Future<Result<Task?>> getTaskById(String taskId);
}
