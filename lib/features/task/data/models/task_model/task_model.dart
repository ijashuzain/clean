import 'package:logit/features/task/domain/entities/task/task.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
class SubTaskModel with _$SubTaskModel {
  const SubTaskModel._();

  const factory SubTaskModel({
    required String id,
    required String title,
    required bool isCompleted,
  }) = _SubTaskModel;

  factory SubTaskModel.fromJson(Map<String, dynamic> json) =>
      _$SubTaskModelFromJson(json);

  SubTask toEntity() => SubTask(id: id, title: title, isCompleted: isCompleted);

  factory SubTaskModel.fromEntity(SubTask entity) {
    return SubTaskModel(
      id: entity.id,
      title: entity.title,
      isCompleted: entity.isCompleted,
    );
  }
}

@freezed
class TaskReminderModel with _$TaskReminderModel {
  const TaskReminderModel._();

  const factory TaskReminderModel({
    required String id,
    required DateTime date,
    required int minuteOfDay,
    @Default(false) bool repeatsDaily,
  }) = _TaskReminderModel;

  factory TaskReminderModel.fromJson(Map<String, dynamic> json) =>
      _$TaskReminderModelFromJson(json);

  TaskReminder toEntity() {
    return TaskReminder(
      id: id,
      date: date,
      minuteOfDay: minuteOfDay,
      repeatsDaily: repeatsDaily,
    );
  }

  factory TaskReminderModel.fromEntity(TaskReminder entity) {
    return TaskReminderModel(
      id: entity.id,
      date: entity.date,
      minuteOfDay: entity.minuteOfDay,
      repeatsDaily: entity.repeatsDaily,
    );
  }
}

@freezed
class TaskModel with _$TaskModel {
  const TaskModel._();

  const factory TaskModel({
    required String id,
    required String title,
    required String topic,
    required String note,
    required String iconKey,
    required DateTime scheduledAt,
    DateTime? endDate,
    int? startMinuteOfDay,
    int? endMinuteOfDay,
    @Default(<TaskReminderModel>[]) List<TaskReminderModel> reminders,
    DateTime? reminderDate,
    int? reminderMinuteOfDay,
    @Default(false) bool repeatsDaily,
    required bool isCompleted,
    required List<SubTaskModel> subtasks,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Task toEntity() {
    return Task(
      id: id,
      title: title,
      topic: topic,
      note: note,
      iconKey: iconKey,
      scheduledAt: scheduledAt,
      endDate: endDate,
      startMinuteOfDay: startMinuteOfDay,
      endMinuteOfDay: endMinuteOfDay,
      reminders: reminders
          .map((reminder) => reminder.toEntity())
          .toList(growable: false),
      reminderDate: reminderDate,
      reminderMinuteOfDay: reminderMinuteOfDay,
      repeatsDaily: repeatsDaily,
      isCompleted: isCompleted,
      subtasks: subtasks
          .map((subtask) => subtask.toEntity())
          .toList(growable: false),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory TaskModel.fromEntity(Task entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      topic: entity.topic,
      note: entity.note,
      iconKey: entity.iconKey,
      scheduledAt: entity.scheduledAt,
      endDate: entity.endDate,
      startMinuteOfDay: entity.startMinuteOfDay,
      endMinuteOfDay: entity.endMinuteOfDay,
      reminders: entity.reminders
          .map(TaskReminderModel.fromEntity)
          .toList(growable: false),
      reminderDate: entity.reminderDate,
      reminderMinuteOfDay: entity.reminderMinuteOfDay,
      repeatsDaily: entity.repeatsDaily,
      isCompleted: entity.isCompleted,
      subtasks: entity.subtasks
          .map(SubTaskModel.fromEntity)
          .toList(growable: false),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
