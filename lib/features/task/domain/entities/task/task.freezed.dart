// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SubTask _$SubTaskFromJson(Map<String, dynamic> json) {
  return _SubTask.fromJson(json);
}

/// @nodoc
mixin _$SubTask {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;

  /// Serializes this SubTask to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubTask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubTaskCopyWith<SubTask> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubTaskCopyWith<$Res> {
  factory $SubTaskCopyWith(SubTask value, $Res Function(SubTask) then) =
      _$SubTaskCopyWithImpl<$Res, SubTask>;
  @useResult
  $Res call({String id, String title, bool isCompleted});
}

/// @nodoc
class _$SubTaskCopyWithImpl<$Res, $Val extends SubTask>
    implements $SubTaskCopyWith<$Res> {
  _$SubTaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubTask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? isCompleted = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubTaskImplCopyWith<$Res> implements $SubTaskCopyWith<$Res> {
  factory _$$SubTaskImplCopyWith(
    _$SubTaskImpl value,
    $Res Function(_$SubTaskImpl) then,
  ) = __$$SubTaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String title, bool isCompleted});
}

/// @nodoc
class __$$SubTaskImplCopyWithImpl<$Res>
    extends _$SubTaskCopyWithImpl<$Res, _$SubTaskImpl>
    implements _$$SubTaskImplCopyWith<$Res> {
  __$$SubTaskImplCopyWithImpl(
    _$SubTaskImpl _value,
    $Res Function(_$SubTaskImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubTask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? isCompleted = null,
  }) {
    return _then(
      _$SubTaskImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubTaskImpl implements _SubTask {
  const _$SubTaskImpl({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  factory _$SubTaskImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubTaskImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  @JsonKey()
  final bool isCompleted;

  @override
  String toString() {
    return 'SubTask(id: $id, title: $title, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubTaskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, isCompleted);

  /// Create a copy of SubTask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubTaskImplCopyWith<_$SubTaskImpl> get copyWith =>
      __$$SubTaskImplCopyWithImpl<_$SubTaskImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubTaskImplToJson(this);
  }
}

abstract class _SubTask implements SubTask {
  const factory _SubTask({
    required final String id,
    required final String title,
    final bool isCompleted,
  }) = _$SubTaskImpl;

  factory _SubTask.fromJson(Map<String, dynamic> json) = _$SubTaskImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  bool get isCompleted;

  /// Create a copy of SubTask
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubTaskImplCopyWith<_$SubTaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Task _$TaskFromJson(Map<String, dynamic> json) {
  return _Task.fromJson(json);
}

/// @nodoc
mixin _$Task {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get topic => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;
  String get iconKey => throw _privateConstructorUsedError;
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  int? get startMinuteOfDay => throw _privateConstructorUsedError;
  int? get endMinuteOfDay => throw _privateConstructorUsedError;
  DateTime? get reminderDate => throw _privateConstructorUsedError;
  int? get reminderMinuteOfDay => throw _privateConstructorUsedError;
  bool get repeatsDaily => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  List<SubTask> get subtasks => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Task to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskCopyWith<Task> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskCopyWith<$Res> {
  factory $TaskCopyWith(Task value, $Res Function(Task) then) =
      _$TaskCopyWithImpl<$Res, Task>;
  @useResult
  $Res call({
    String id,
    String title,
    String topic,
    String note,
    String iconKey,
    DateTime scheduledAt,
    DateTime? endDate,
    int? startMinuteOfDay,
    int? endMinuteOfDay,
    DateTime? reminderDate,
    int? reminderMinuteOfDay,
    bool repeatsDaily,
    bool isCompleted,
    List<SubTask> subtasks,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$TaskCopyWithImpl<$Res, $Val extends Task>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? topic = null,
    Object? note = null,
    Object? iconKey = null,
    Object? scheduledAt = null,
    Object? endDate = freezed,
    Object? startMinuteOfDay = freezed,
    Object? endMinuteOfDay = freezed,
    Object? reminderDate = freezed,
    Object? reminderMinuteOfDay = freezed,
    Object? repeatsDaily = null,
    Object? isCompleted = null,
    Object? subtasks = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            topic: null == topic
                ? _value.topic
                : topic // ignore: cast_nullable_to_non_nullable
                      as String,
            note: null == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String,
            iconKey: null == iconKey
                ? _value.iconKey
                : iconKey // ignore: cast_nullable_to_non_nullable
                      as String,
            scheduledAt: null == scheduledAt
                ? _value.scheduledAt
                : scheduledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            startMinuteOfDay: freezed == startMinuteOfDay
                ? _value.startMinuteOfDay
                : startMinuteOfDay // ignore: cast_nullable_to_non_nullable
                      as int?,
            endMinuteOfDay: freezed == endMinuteOfDay
                ? _value.endMinuteOfDay
                : endMinuteOfDay // ignore: cast_nullable_to_non_nullable
                      as int?,
            reminderDate: freezed == reminderDate
                ? _value.reminderDate
                : reminderDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            reminderMinuteOfDay: freezed == reminderMinuteOfDay
                ? _value.reminderMinuteOfDay
                : reminderMinuteOfDay // ignore: cast_nullable_to_non_nullable
                      as int?,
            repeatsDaily: null == repeatsDaily
                ? _value.repeatsDaily
                : repeatsDaily // ignore: cast_nullable_to_non_nullable
                      as bool,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            subtasks: null == subtasks
                ? _value.subtasks
                : subtasks // ignore: cast_nullable_to_non_nullable
                      as List<SubTask>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TaskImplCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$$TaskImplCopyWith(
    _$TaskImpl value,
    $Res Function(_$TaskImpl) then,
  ) = __$$TaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String topic,
    String note,
    String iconKey,
    DateTime scheduledAt,
    DateTime? endDate,
    int? startMinuteOfDay,
    int? endMinuteOfDay,
    DateTime? reminderDate,
    int? reminderMinuteOfDay,
    bool repeatsDaily,
    bool isCompleted,
    List<SubTask> subtasks,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$TaskImplCopyWithImpl<$Res>
    extends _$TaskCopyWithImpl<$Res, _$TaskImpl>
    implements _$$TaskImplCopyWith<$Res> {
  __$$TaskImplCopyWithImpl(_$TaskImpl _value, $Res Function(_$TaskImpl) _then)
    : super(_value, _then);

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? topic = null,
    Object? note = null,
    Object? iconKey = null,
    Object? scheduledAt = null,
    Object? endDate = freezed,
    Object? startMinuteOfDay = freezed,
    Object? endMinuteOfDay = freezed,
    Object? reminderDate = freezed,
    Object? reminderMinuteOfDay = freezed,
    Object? repeatsDaily = null,
    Object? isCompleted = null,
    Object? subtasks = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$TaskImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        topic: null == topic
            ? _value.topic
            : topic // ignore: cast_nullable_to_non_nullable
                  as String,
        note: null == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String,
        iconKey: null == iconKey
            ? _value.iconKey
            : iconKey // ignore: cast_nullable_to_non_nullable
                  as String,
        scheduledAt: null == scheduledAt
            ? _value.scheduledAt
            : scheduledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        startMinuteOfDay: freezed == startMinuteOfDay
            ? _value.startMinuteOfDay
            : startMinuteOfDay // ignore: cast_nullable_to_non_nullable
                  as int?,
        endMinuteOfDay: freezed == endMinuteOfDay
            ? _value.endMinuteOfDay
            : endMinuteOfDay // ignore: cast_nullable_to_non_nullable
                  as int?,
        reminderDate: freezed == reminderDate
            ? _value.reminderDate
            : reminderDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        reminderMinuteOfDay: freezed == reminderMinuteOfDay
            ? _value.reminderMinuteOfDay
            : reminderMinuteOfDay // ignore: cast_nullable_to_non_nullable
                  as int?,
        repeatsDaily: null == repeatsDaily
            ? _value.repeatsDaily
            : repeatsDaily // ignore: cast_nullable_to_non_nullable
                  as bool,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        subtasks: null == subtasks
            ? _value._subtasks
            : subtasks // ignore: cast_nullable_to_non_nullable
                  as List<SubTask>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskImpl implements _Task {
  const _$TaskImpl({
    required this.id,
    required this.title,
    this.topic = '',
    this.note = '',
    this.iconKey = '',
    required this.scheduledAt,
    this.endDate,
    this.startMinuteOfDay,
    this.endMinuteOfDay,
    this.reminderDate,
    this.reminderMinuteOfDay,
    this.repeatsDaily = false,
    this.isCompleted = false,
    final List<SubTask> subtasks = const <SubTask>[],
    required this.createdAt,
    required this.updatedAt,
  }) : _subtasks = subtasks;

  factory _$TaskImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  @JsonKey()
  final String topic;
  @override
  @JsonKey()
  final String note;
  @override
  @JsonKey()
  final String iconKey;
  @override
  final DateTime scheduledAt;
  @override
  final DateTime? endDate;
  @override
  final int? startMinuteOfDay;
  @override
  final int? endMinuteOfDay;
  @override
  final DateTime? reminderDate;
  @override
  final int? reminderMinuteOfDay;
  @override
  @JsonKey()
  final bool repeatsDaily;
  @override
  @JsonKey()
  final bool isCompleted;
  final List<SubTask> _subtasks;
  @override
  @JsonKey()
  List<SubTask> get subtasks {
    if (_subtasks is EqualUnmodifiableListView) return _subtasks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subtasks);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Task(id: $id, title: $title, topic: $topic, note: $note, iconKey: $iconKey, scheduledAt: $scheduledAt, endDate: $endDate, startMinuteOfDay: $startMinuteOfDay, endMinuteOfDay: $endMinuteOfDay, reminderDate: $reminderDate, reminderMinuteOfDay: $reminderMinuteOfDay, repeatsDaily: $repeatsDaily, isCompleted: $isCompleted, subtasks: $subtasks, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.topic, topic) || other.topic == topic) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.iconKey, iconKey) || other.iconKey == iconKey) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.startMinuteOfDay, startMinuteOfDay) ||
                other.startMinuteOfDay == startMinuteOfDay) &&
            (identical(other.endMinuteOfDay, endMinuteOfDay) ||
                other.endMinuteOfDay == endMinuteOfDay) &&
            (identical(other.reminderDate, reminderDate) ||
                other.reminderDate == reminderDate) &&
            (identical(other.reminderMinuteOfDay, reminderMinuteOfDay) ||
                other.reminderMinuteOfDay == reminderMinuteOfDay) &&
            (identical(other.repeatsDaily, repeatsDaily) ||
                other.repeatsDaily == repeatsDaily) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            const DeepCollectionEquality().equals(other._subtasks, _subtasks) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    topic,
    note,
    iconKey,
    scheduledAt,
    endDate,
    startMinuteOfDay,
    endMinuteOfDay,
    reminderDate,
    reminderMinuteOfDay,
    repeatsDaily,
    isCompleted,
    const DeepCollectionEquality().hash(_subtasks),
    createdAt,
    updatedAt,
  );

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      __$$TaskImplCopyWithImpl<_$TaskImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskImplToJson(this);
  }
}

abstract class _Task implements Task {
  const factory _Task({
    required final String id,
    required final String title,
    final String topic,
    final String note,
    final String iconKey,
    required final DateTime scheduledAt,
    final DateTime? endDate,
    final int? startMinuteOfDay,
    final int? endMinuteOfDay,
    final DateTime? reminderDate,
    final int? reminderMinuteOfDay,
    final bool repeatsDaily,
    final bool isCompleted,
    final List<SubTask> subtasks,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$TaskImpl;

  factory _Task.fromJson(Map<String, dynamic> json) = _$TaskImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get topic;
  @override
  String get note;
  @override
  String get iconKey;
  @override
  DateTime get scheduledAt;
  @override
  DateTime? get endDate;
  @override
  int? get startMinuteOfDay;
  @override
  int? get endMinuteOfDay;
  @override
  DateTime? get reminderDate;
  @override
  int? get reminderMinuteOfDay;
  @override
  bool get repeatsDaily;
  @override
  bool get isCompleted;
  @override
  List<SubTask> get subtasks;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
