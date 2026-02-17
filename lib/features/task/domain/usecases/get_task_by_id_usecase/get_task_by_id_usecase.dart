import 'package:logit/core/usecases/usecase.dart';
import 'package:logit/core/utils/result/result.dart';
import 'package:logit/features/task/data/repositories/task_repository_impl/task_repository_impl.dart';
import 'package:logit/features/task/domain/entities/task/task.dart';
import 'package:logit/features/task/domain/repositories/task_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_task_by_id_usecase.g.dart';

@riverpod
GetTaskByIdUseCase getTaskByIdUseCase(Ref ref) {
  return GetTaskByIdUseCase(taskRepository: ref.watch(taskRepositoryProvider));
}

class GetTaskByIdUseCase implements UseCase<Task?, String> {
  final TaskRepository taskRepository;

  GetTaskByIdUseCase({required this.taskRepository});

  @override
  Future<Result<Task?>> call(String params) async {
    return taskRepository.getTaskById(params);
  }
}
