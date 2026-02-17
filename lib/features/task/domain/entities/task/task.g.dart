// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubTaskImpl _$$SubTaskImplFromJson(Map<String, dynamic> json) =>
    _$SubTaskImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$SubTaskImplToJson(_$SubTaskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'isCompleted': instance.isCompleted,
    };

_$TaskImpl _$$TaskImplFromJson(Map<String, dynamic> json) => _$TaskImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  topic: json['topic'] as String? ?? '',
  note: json['note'] as String? ?? '',
  iconKey: json['iconKey'] as String? ?? '',
  scheduledAt: DateTime.parse(json['scheduledAt'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  startMinuteOfDay: (json['startMinuteOfDay'] as num?)?.toInt(),
  endMinuteOfDay: (json['endMinuteOfDay'] as num?)?.toInt(),
  repeatsDaily: json['repeatsDaily'] as bool? ?? false,
  isCompleted: json['isCompleted'] as bool? ?? false,
  subtasks:
      (json['subtasks'] as List<dynamic>?)
          ?.map((e) => SubTask.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SubTask>[],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$TaskImplToJson(_$TaskImpl instance) =>
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
      'repeatsDaily': instance.repeatsDaily,
      'isCompleted': instance.isCompleted,
      'subtasks': instance.subtasks,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
