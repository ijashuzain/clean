import 'package:logit/core/usecases/usecase.dart';
import 'package:logit/core/utils/result/result.dart';
import 'package:logit/features/task/data/repositories/task_repository_impl/task_repository_impl.dart';
import 'package:logit/features/task/domain/repositories/task_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_emoji_preview_usecase.g.dart';

@riverpod
GetEmojiPreviewUseCase getEmojiPreviewUseCase(Ref ref) {
  return GetEmojiPreviewUseCase(
    taskRepository: ref.watch(taskRepositoryProvider),
  );
}

class GetEmojiPreviewUseCase
    implements UseCase<Map<String, List<String>>, EmojiPreviewParams> {
  final TaskRepository taskRepository;

  GetEmojiPreviewUseCase({required this.taskRepository});

  @override
  Future<Result<Map<String, List<String>>>> call(
    EmojiPreviewParams params,
  ) async {
    return taskRepository.getEmojiPreviewForRange(
      from: params.from,
      to: params.to,
    );
  }
}

class EmojiPreviewParams {
  final DateTime from;
  final DateTime to;

  EmojiPreviewParams({required this.from, required this.to});
}
