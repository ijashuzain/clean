// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubTaskModelImpl _$$SubTaskModelImplFromJson(Map<String, dynamic> json) =>
    _$SubTaskModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
    );

Map<String, dynamic> _$$SubTaskModelImplToJson(_$SubTaskModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'isCompleted': instance.isCompleted,
    };

_$TaskModelImpl _$$TaskModelImplFromJson(Map<String, dynamic> json) =>
    _$TaskModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      topic: json['topic'] as String,
      note: json['note'] as String,
      iconKey: json['iconKey'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      startMinuteOfDay: (json['startMinuteOfDay'] as num?)?.toInt(),
      endMinuteOfDay: (json['endMinuteOfDay'] as num?)?.toInt(),
      reminderDate: json['reminderDate'] == null
          ? null
          : DateTime.parse(json['reminderDate'] as String),
      reminderMinuteOfDay: (json['reminderMinuteOfDay'] as num?)?.toInt(),
      repeatsDaily: json['repeatsDaily'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool,
      subtasks: (json['subtasks'] as List<dynamic>)
          .map((e) => SubTaskModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TaskModelImplToJson(_$TaskModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'topic': instance.topic,
      'note': instance.note,
      'iconKey': instance.iconKey,
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'startMinuteOfDay': instance.startMinuteOfDay,
      'endMinuteOfDay': instance.endMinuteOfDay,
      'reminderDate': instance.reminderDate?.toIso8601String(),
      'reminderMinuteOfDay': instance.reminderMinuteOfDay,
      'repeatsDaily': instance.repeatsDaily,
      'isCompleted': instance.isCompleted,
      'subtasks': instance.subtasks,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
