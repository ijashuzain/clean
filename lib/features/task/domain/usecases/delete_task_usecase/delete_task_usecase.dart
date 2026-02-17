import 'package:logit/core/usecases/usecase.dart';
import 'package:logit/core/utils/result/result.dart';
import 'package:logit/features/task/data/repositories/task_repository_impl/task_repository_impl.dart';
import 'package:logit/features/task/domain/repositories/task_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_task_usecase.g.dart';

@riverpod
DeleteTaskUseCase deleteTaskUseCase(Ref ref) {
  return DeleteTaskUseCase(taskRepository: ref.watch(taskRepositoryProvider));
}

class DeleteTaskUseCase implements UseCase<void, String> {
  final TaskRepository taskRepository;

  DeleteTaskUseCase({required this.taskRepository});

  @override
  Future<Result<void>> call(String params) async {
    return taskRepository.deleteTask(params);
  }
}
