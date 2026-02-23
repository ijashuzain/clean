import 'package:logit/core/usecases/usecase.dart';
import 'package:logit/core/utils/result/result.dart';
import 'package:logit/features/task/data/repositories/task_repository_impl/task_repository_impl.dart';
import 'package:logit/features/task/domain/entities/task/task.dart';
import 'package:logit/features/task/domain/repositories/task_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_all_tasks_usecase.g.dart';

@riverpod
GetAllTasksUseCase getAllTasksUseCase(Ref ref) {
  return GetAllTasksUseCase(taskRepository: ref.watch(taskRepositoryProvider));
}

class GetAllTasksUseCase implements UseCaseNoParams<List<Task>> {
  final TaskRepository taskRepository;

  GetAllTasksUseCase({required this.taskRepository});

  @override
  Future<Result<List<Task>>> call() async {
    return taskRepository.getAllTasks();
  }
}
