import 'package:logit/core/usecases/usecase.dart';
import 'package:logit/core/utils/result/result.dart';
import 'package:logit/features/task/data/repositories/task_repository_impl/task_repository_impl.dart';
import 'package:logit/features/task/domain/entities/task/task.dart';
import 'package:logit/features/task/domain/repositories/task_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_tasks_by_date_usecase.g.dart';

@riverpod
GetTasksByDateUseCase getTasksByDateUseCase(Ref ref) {
  return GetTasksByDateUseCase(
    taskRepository: ref.watch(taskRepositoryProvider),
  );
}

class GetTasksByDateUseCase implements UseCase<List<Task>, DateTime> {
  final TaskRepository taskRepository;

  GetTasksByDateUseCase({required this.taskRepository});

  @override
  Future<Result<List<Task>>> call(DateTime params) async {
    return taskRepository.getTasksByDate(params);
  }
}
