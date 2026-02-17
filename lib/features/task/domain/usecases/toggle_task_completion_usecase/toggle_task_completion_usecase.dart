import 'package:logit/core/usecases/usecase.dart';
import 'package:logit/core/utils/result/result.dart';
import 'package:logit/features/task/data/repositories/task_repository_impl/task_repository_impl.dart';
import 'package:logit/features/task/domain/repositories/task_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'toggle_task_completion_usecase.g.dart';

@riverpod
ToggleTaskCompletionUseCase toggleTaskCompletionUseCase(Ref ref) {
  return ToggleTaskCompletionUseCase(
    taskRepository: ref.watch(taskRepositoryProvider),
  );
}

class ToggleTaskCompletionUseCase
    implements UseCase<void, ToggleTaskCompletionParams> {
  final TaskRepository taskRepository;

  ToggleTaskCompletionUseCase({required this.taskRepository});

  @override
  Future<Result<void>> call(ToggleTaskCompletionParams params) async {
    return taskRepository.toggleTaskCompletion(
      taskId: params.taskId,
      subTaskId: params.subTaskId,
    );
  }
}

class ToggleTaskCompletionParams {
  final String taskId;
  final String? subTaskId;

  ToggleTaskCompletionParams({required this.taskId, this.subTaskId});
}
