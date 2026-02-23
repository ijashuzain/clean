import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class SubTask with _$SubTask {
  const factory SubTask({
    required String id,
    required String title,
    @Default(false) bool isCompleted,
  }) = _SubTask;

  factory SubTask.fromJson(Map<String, dynamic> json) =>
      _$SubTaskFromJson(json);
}

@freezed
class TaskReminder with _$TaskReminder {
  const factory TaskReminder({
    required String id,
    required DateTime date,
    required int minuteOfDay,
    @Default(false) bool repeatsDaily,
  }) = _TaskReminder;

  factory TaskReminder.fromJson(Map<String, dynamic> json) =>
      _$TaskReminderFromJson(json);
}

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    @Default('') String topic,
    @Default('') String note,
    @Default('') String iconKey,
    required DateTime scheduledAt,
    DateTime? endDate,
    int? startMinuteOfDay,
    int? endMinuteOfDay,
    @Default(<TaskReminder>[]) List<TaskReminder> reminders,
    DateTime? reminderDate,
    int? reminderMinuteOfDay,
    @Default(false) bool repeatsDaily,
    @Default(false) bool isCompleted,
    @Default(<SubTask>[]) List<SubTask> subtasks,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}
