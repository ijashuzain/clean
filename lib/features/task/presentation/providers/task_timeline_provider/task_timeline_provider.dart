import 'package:logit/core/utils/status/status.dart';
import 'package:logit/features/task/domain/entities/task/task.dart';
import 'package:logit/features/task/domain/usecases/delete_task_usecase/delete_task_usecase.dart';
import 'package:logit/features/task/domain/usecases/get_emoji_preview_usecase/get_emoji_preview_usecase.dart';
import 'package:logit/features/task/domain/usecases/get_task_by_id_usecase/get_task_by_id_usecase.dart';
import 'package:logit/features/task/domain/usecases/get_tasks_by_date_usecase/get_tasks_by_date_usecase.dart';
import 'package:logit/features/task/domain/usecases/save_task_usecase/save_task_usecase.dart';
import 'package:logit/features/task/domain/usecases/toggle_task_completion_usecase/toggle_task_completion_usecase.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_timeline_provider.freezed.dart';
part 'task_timeline_provider.g.dart';

@freezed
class TaskTimelineState with _$TaskTimelineState {
  const factory TaskTimelineState({
    required DateTime selectedDate,
    @Default(<Task>[]) List<Task> tasks,
    @Default(<String, List<String>>{}) Map<String, List<String>> weekEmojiMap,
    @Default(Status.initial()) Status taskStatus,
  }) = _TaskTimelineState;
}

@riverpod
class TaskTimelineProvider extends _$TaskTimelineProvider {
  @override
  TaskTimelineState build() {
    final today = _toDateOnly(DateTime.now());
    Future.microtask(() => loadTasks(today));
    return TaskTimelineState(selectedDate: today);
  }

  Future<void> loadTasks([DateTime? date]) async {
    final targetDate = _toDateOnly(date ?? state.selectedDate);
    final weekStart = targetDate.subtract(
      Duration(days: targetDate.weekday - 1),
    );
    final weekEnd = weekStart.add(const Duration(days: 6));
    state = state.copyWith(
      taskStatus: Status.loading(),
      selectedDate: targetDate,
    );

    final result = await ref
        .read(getTasksByDateUseCaseProvider)
        .call(targetDate);
    result.when(
      success: (tasks) {
        state = state.copyWith(taskStatus: Status.success(), tasks: tasks);
        _loadWeekEmojiMap(weekStart: weekStart, weekEnd: weekEnd);
      },
      failure: (failure) {
        state = state.copyWith(taskStatus: Status.failure(failure.message));
      },
    );
  }

  Future<void> _loadWeekEmojiMap({
    required DateTime weekStart,
    required DateTime weekEnd,
  }) async {
    final result = await ref
        .read(getEmojiPreviewUseCaseProvider)
        .call(EmojiPreviewParams(from: weekStart, to: weekEnd));
    result.when(
      success: (emojiMap) {
        state = state.copyWith(weekEmojiMap: emojiMap);
      },
      failure: (_) {},
    );
  }

  Future<void> saveTask(Task task) async {
    final result = await ref.read(saveTaskUseCaseProvider).call(task);
    result.when(
      success: (_) => loadTasks(task.scheduledAt),
      failure: (failure) =>
          state = state.copyWith(taskStatus: Status.failure(failure.message)),
    );
  }

  Future<void> toggleTask({required String taskId, String? subTaskId}) async {
    final result = await ref
        .read(toggleTaskCompletionUseCaseProvider)
        .call(ToggleTaskCompletionParams(taskId: taskId, subTaskId: subTaskId));

    result.when(
      success: (_) => loadTasks(state.selectedDate),
      failure: (failure) =>
          state = state.copyWith(taskStatus: Status.failure(failure.message)),
    );
  }

  Future<void> deleteTask(String taskId) async {
    final result = await ref.read(deleteTaskUseCaseProvider).call(taskId);
    result.when(
      success: (_) => loadTasks(state.selectedDate),
      failure: (failure) =>
          state = state.copyWith(taskStatus: Status.failure(failure.message)),
    );
  }

  Future<Task?> getTaskById(String taskId) async {
    final result = await ref.read(getTaskByIdUseCaseProvider).call(taskId);
    return result.when(success: (task) => task, failure: (_) => null);
  }

  DateTime _toDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
