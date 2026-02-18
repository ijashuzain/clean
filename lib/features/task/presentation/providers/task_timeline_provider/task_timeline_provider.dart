import 'package:logit/core/notifications/task_reminder_scheduler.dart';
import 'package:logit/core/utils/status/status.dart';
import 'package:logit/features/task/domain/entities/task/task.dart';
import 'package:logit/features/task/domain/usecases/delete_task_usecase/delete_task_usecase.dart';
import 'package:logit/features/task/domain/usecases/get_emoji_preview_usecase/get_emoji_preview_usecase.dart';
import 'package:logit/features/task/domain/usecases/get_all_tasks_usecase/get_all_tasks_usecase.dart';
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
    Future.microtask(() async {
      await ref.read(taskReminderSchedulerProvider).ensureInitialized();
      await _syncAllTaskReminders();
      await loadTasks(today);
    });
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
    await result.when(
      success: (_) async {
        await ref.read(taskReminderSchedulerProvider).syncForTask(task);
        await loadTasks(task.scheduledAt);
      },
      failure: (failure) async {
        state = state.copyWith(taskStatus: Status.failure(failure.message));
      },
    );
  }

  Future<void> toggleTask({required String taskId, String? subTaskId}) async {
    final result = await ref
        .read(toggleTaskCompletionUseCaseProvider)
        .call(ToggleTaskCompletionParams(taskId: taskId, subTaskId: subTaskId));

    await result.when(
      success: (_) async {
        final updatedTaskResult = await ref
            .read(getTaskByIdUseCaseProvider)
            .call(taskId);
        await updatedTaskResult.when(
          success: (task) async {
            if (task == null) {
              await ref
                  .read(taskReminderSchedulerProvider)
                  .cancelForTaskId(taskId);
              return;
            }
            await ref.read(taskReminderSchedulerProvider).syncForTask(task);
          },
          failure: (_) async {
            await ref
                .read(taskReminderSchedulerProvider)
                .cancelForTaskId(taskId);
          },
        );
        await loadTasks(state.selectedDate);
      },
      failure: (failure) async {
        state = state.copyWith(taskStatus: Status.failure(failure.message));
      },
    );
  }

  Future<void> deleteTask(String taskId) async {
    final result = await ref.read(deleteTaskUseCaseProvider).call(taskId);
    await result.when(
      success: (_) async {
        await ref.read(taskReminderSchedulerProvider).cancelForTaskId(taskId);
        await loadTasks(state.selectedDate);
      },
      failure: (failure) async {
        state = state.copyWith(taskStatus: Status.failure(failure.message));
      },
    );
  }

  Future<Task?> getTaskById(String taskId) async {
    final result = await ref.read(getTaskByIdUseCaseProvider).call(taskId);
    return result.when(success: (task) => task, failure: (_) => null);
  }

  DateTime _toDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _syncAllTaskReminders() async {
    final result = await ref.read(getAllTasksUseCaseProvider).call();
    await result.when(
      success: (tasks) async {
        await ref.read(taskReminderSchedulerProvider).syncForTasks(tasks);
      },
      failure: (_) async {},
    );
  }
}
