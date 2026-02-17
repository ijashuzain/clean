import 'package:logit/core/failure/failure.dart';
import 'package:logit/core/usecases/usecase.dart';
import 'package:logit/core/utils/result/result.dart';
import 'package:logit/features/task/data/repositories/task_repository_impl/task_repository_impl.dart';
import 'package:logit/features/task/domain/entities/task/task.dart';
import 'package:logit/features/task/domain/repositories/task_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'save_task_usecase.g.dart';

@riverpod
SaveTaskUseCase saveTaskUseCase(Ref ref) {
  return SaveTaskUseCase(taskRepository: ref.watch(taskRepositoryProvider));
}

class SaveTaskUseCase implements UseCase<void, Task> {
  final TaskRepository taskRepository;

  SaveTaskUseCase({required this.taskRepository});

  @override
  Future<Result<void>> call(Task params) async {
    if (params.title.trim().isEmpty) {
      return Result.failure(
        Failure.validationFailure(message: 'Task title is required'),
      );
    }
    return taskRepository.upsertTask(params);
  }
}
