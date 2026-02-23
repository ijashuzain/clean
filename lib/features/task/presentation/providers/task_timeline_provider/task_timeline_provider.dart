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
    final scheduler = ref.read(taskReminderSchedulerProvider);
    ref.onDispose(scheduler.dispose);

    Future.microtask(() async {
      await scheduler.ensureInitialized();
      scheduler.startForegroundReminderLoop(loadTasks: _getAllTasksOrEmpty);
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
    await result.when(
      success: (tasks) async {
        final normalizedTasks = await _normalizeCarriedTasksForToday(
          tasks,
          targetDate: targetDate,
        );
        state = state.copyWith(
          taskStatus: Status.success(),
          tasks: normalizedTasks,
        );
        _loadWeekEmojiMap(weekStart: weekStart, weekEnd: weekEnd);
      },
      failure: (failure) async {
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
    final scheduler = ref.read(taskReminderSchedulerProvider);
    final now = DateTime.now();
    final sanitizedTask = _pruneTaskReminders(
      task,
      scheduler: scheduler,
      now: now,
    );
    final result = await ref.read(saveTaskUseCaseProvider).call(sanitizedTask);
    await result.when(
      success: (_) async {
        await scheduler.syncForTask(sanitizedTask);
        await loadTasks(sanitizedTask.scheduledAt);
      },
      failure: (failure) async {
        state = state.copyWith(taskStatus: Status.failure(failure.message));
      },
    );
  }

  Future<void> toggleTask({required String taskId, String? subTaskId}) async {
    final result = await ref
        .read(toggleTaskCompletionUseCaseProvider)
        .call(
          ToggleTaskCompletionParams(
            taskId: taskId,
            forDate: state.selectedDate,
            subTaskId: subTaskId,
          ),
        );

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
        await _syncAllTaskReminders();
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
    final scheduler = ref.read(taskReminderSchedulerProvider);
    final result = await ref.read(getAllTasksUseCaseProvider).call();
    await result.when(
      success: (tasks) async {
        final normalizedTasks = await _pruneAndPersistPastReminders(
          tasks,
          scheduler: scheduler,
        );
        await scheduler.syncForTasks(normalizedTasks);
      },
      failure: (_) async {},
    );
  }

  Future<List<Task>> _getAllTasksOrEmpty() async {
    final result = await ref.read(getAllTasksUseCaseProvider).call();
    return result.when(success: (tasks) => tasks, failure: (_) => const []);
  }

  Future<List<Task>> _pruneAndPersistPastReminders(
    List<Task> tasks, {
    required TaskReminderScheduler scheduler,
  }) async {
    final now = DateTime.now();
    final output = <Task>[];

    for (final task in tasks) {
      final sanitizedTask = _pruneTaskReminders(
        task,
        scheduler: scheduler,
        now: now,
      );
      output.add(sanitizedTask);
      if (_sameReminderCollection(task.reminders, sanitizedTask.reminders)) {
        continue;
      }
      await ref.read(saveTaskUseCaseProvider).call(sanitizedTask);
    }

    return output.toList(growable: false);
  }

  Task _pruneTaskReminders(
    Task task, {
    required TaskReminderScheduler scheduler,
    required DateTime now,
  }) {
    if (task.reminders.isEmpty) {
      return task;
    }

    final activeReminders = task.reminders
        .where(
          (reminder) =>
              scheduler.hasUpcomingOccurrence(task, reminder, now: now),
        )
        .map((reminder) => reminder.copyWith(date: _toDateOnly(reminder.date)))
        .toList(growable: false);

    if (_sameReminderCollection(task.reminders, activeReminders)) {
      return task;
    }
    return task.copyWith(reminders: activeReminders, updatedAt: now);
  }

  bool _sameReminderCollection(
    List<TaskReminder> first,
    List<TaskReminder> second,
  ) {
    if (first.length != second.length) {
      return false;
    }
    final firstSet = first.map(_reminderSignature).toSet();
    final secondSet = second.map(_reminderSignature).toSet();
    return firstSet.length == secondSet.length &&
        firstSet.containsAll(secondSet);
  }

  String _reminderSignature(TaskReminder reminder) {
    final day = _toDateOnly(reminder.date);
    return '${reminder.id}|${day.year}-${day.month}-${day.day}|'
        '${reminder.minuteOfDay}|${reminder.repeatsDaily}';
  }

  Future<List<Task>> _normalizeCarriedTasksForToday(
    List<Task> tasks, {
    required DateTime targetDate,
  }) async {
    final today = _toDateOnly(DateTime.now());
    if (!_sameDate(targetDate, today)) {
      return tasks;
    }

    final scheduler = ref.read(taskReminderSchedulerProvider);
    final normalizedTasks = <Task>[];

    for (final task in tasks) {
      if (!_needsCarryDateNormalization(task, today)) {
        normalizedTasks.add(task);
        continue;
      }

      final normalizedTask = task.copyWith(
        endDate: today,
        updatedAt: DateTime.now(),
      );
      final saveResult = await ref
          .read(saveTaskUseCaseProvider)
          .call(normalizedTask);
      await saveResult.when(
        success: (_) async {
          await scheduler.syncForTask(normalizedTask);
          normalizedTasks.add(normalizedTask);
        },
        failure: (_) async {
          normalizedTasks.add(task);
        },
      );
    }

    return normalizedTasks.toList(growable: false);
  }

  bool _needsCarryDateNormalization(Task task, DateTime today) {
    if (_isTaskFinished(task)) {
      return false;
    }
    if (task.repeatsDaily && task.endDate == null) {
      return false;
    }
    final start = _toDateOnly(task.scheduledAt);
    if (!start.isBefore(today)) {
      return false;
    }
    final end = task.endDate == null ? null : _toDateOnly(task.endDate!);
    return end == null || end.isBefore(today);
  }

  bool _isTaskFinished(Task task) {
    if (task.isCompleted) {
      return true;
    }
    return task.subtasks.isNotEmpty &&
        task.subtasks.every((subtask) => subtask.isCompleted);
  }

  bool _sameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
