// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SubTaskModel _$SubTaskModelFromJson(Map<String, dynamic> json) {
  return _SubTaskModel.fromJson(json);
}

/// @nodoc
mixin _$SubTaskModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;

  /// Serializes this SubTaskModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubTaskModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubTaskModelCopyWith<SubTaskModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubTaskModelCopyWith<$Res> {
  factory $SubTaskModelCopyWith(
    SubTaskModel value,
    $Res Function(SubTaskModel) then,
  ) = _$SubTaskModelCopyWithImpl<$Res, SubTaskModel>;
  @useResult
  $Res call({String id, String title, bool isCompleted});
}

/// @nodoc
class _$SubTaskModelCopyWithImpl<$Res, $Val extends SubTaskModel>
    implements $SubTaskModelCopyWith<$Res> {
  _$SubTaskModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubTaskModel
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
abstract class _$$SubTaskModelImplCopyWith<$Res>
    implements $SubTaskModelCopyWith<$Res> {
  factory _$$SubTaskModelImplCopyWith(
    _$SubTaskModelImpl value,
    $Res Function(_$SubTaskModelImpl) then,
  ) = __$$SubTaskModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String title, bool isCompleted});
}

/// @nodoc
class __$$SubTaskModelImplCopyWithImpl<$Res>
    extends _$SubTaskModelCopyWithImpl<$Res, _$SubTaskModelImpl>
    implements _$$SubTaskModelImplCopyWith<$Res> {
  __$$SubTaskModelImplCopyWithImpl(
    _$SubTaskModelImpl _value,
    $Res Function(_$SubTaskModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubTaskModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? isCompleted = null,
  }) {
    return _then(
      _$SubTaskModelImpl(
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
class _$SubTaskModelImpl extends _SubTaskModel {
  const _$SubTaskModelImpl({
    required this.id,
    required this.title,
    required this.isCompleted,
  }) : super._();

  factory _$SubTaskModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubTaskModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final bool isCompleted;

  @override
  String toString() {
    return 'SubTaskModel(id: $id, title: $title, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubTaskModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, isCompleted);

  /// Create a copy of SubTaskModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubTaskModelImplCopyWith<_$SubTaskModelImpl> get copyWith =>
      __$$SubTaskModelImplCopyWithImpl<_$SubTaskModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubTaskModelImplToJson(this);
  }
}

abstract class _SubTaskModel extends SubTaskModel {
  const factory _SubTaskModel({
    required final String id,
    required final String title,
    required final bool isCompleted,
  }) = _$SubTaskModelImpl;
  const _SubTaskModel._() : super._();

  factory _SubTaskModel.fromJson(Map<String, dynamic> json) =
      _$SubTaskModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  bool get isCompleted;

  /// Create a copy of SubTaskModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubTaskModelImplCopyWith<_$SubTaskModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) {
  return _TaskModel.fromJson(json);
}

/// @nodoc
mixin _$TaskModel {
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
  List<SubTaskModel> get subtasks => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this TaskModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskModelCopyWith<TaskModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskModelCopyWith<$Res> {
  factory $TaskModelCopyWith(TaskModel value, $Res Function(TaskModel) then) =
      _$TaskModelCopyWithImpl<$Res, TaskModel>;
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
    List<SubTaskModel> subtasks,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$TaskModelCopyWithImpl<$Res, $Val extends TaskModel>
    implements $TaskModelCopyWith<$Res> {
  _$TaskModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskModel
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
                      as List<SubTaskModel>,
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
abstract class _$$TaskModelImplCopyWith<$Res>
    implements $TaskModelCopyWith<$Res> {
  factory _$$TaskModelImplCopyWith(
    _$TaskModelImpl value,
    $Res Function(_$TaskModelImpl) then,
  ) = __$$TaskModelImplCopyWithImpl<$Res>;
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
    List<SubTaskModel> subtasks,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$TaskModelImplCopyWithImpl<$Res>
    extends _$TaskModelCopyWithImpl<$Res, _$TaskModelImpl>
    implements _$$TaskModelImplCopyWith<$Res> {
  __$$TaskModelImplCopyWithImpl(
    _$TaskModelImpl _value,
    $Res Function(_$TaskModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaskModel
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
      _$TaskModelImpl(
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
                  as List<SubTaskModel>,
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
class _$TaskModelImpl extends _TaskModel {
  const _$TaskModelImpl({
    required this.id,
    required this.title,
    required this.topic,
    required this.note,
    required this.iconKey,
    required this.scheduledAt,
    this.endDate,
    this.startMinuteOfDay,
    this.endMinuteOfDay,
    this.reminderDate,
    this.reminderMinuteOfDay,
    this.repeatsDaily = false,
    required this.isCompleted,
    required final List<SubTaskModel> subtasks,
    required this.createdAt,
    required this.updatedAt,
  }) : _subtasks = subtasks,
       super._();

  factory _$TaskModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String topic;
  @override
  final String note;
  @override
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
  final bool isCompleted;
  final List<SubTaskModel> _subtasks;
  @override
  List<SubTaskModel> get subtasks {
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
    return 'TaskModel(id: $id, title: $title, topic: $topic, note: $note, iconKey: $iconKey, scheduledAt: $scheduledAt, endDate: $endDate, startMinuteOfDay: $startMinuteOfDay, endMinuteOfDay: $endMinuteOfDay, reminderDate: $reminderDate, reminderMinuteOfDay: $reminderMinuteOfDay, repeatsDaily: $repeatsDaily, isCompleted: $isCompleted, subtasks: $subtasks, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskModelImpl &&
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

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskModelImplCopyWith<_$TaskModelImpl> get copyWith =>
      __$$TaskModelImplCopyWithImpl<_$TaskModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskModelImplToJson(this);
  }
}

abstract class _TaskModel extends TaskModel {
  const factory _TaskModel({
    required final String id,
    required final String title,
    required final String topic,
    required final String note,
    required final String iconKey,
    required final DateTime scheduledAt,
    final DateTime? endDate,
    final int? startMinuteOfDay,
    final int? endMinuteOfDay,
    final DateTime? reminderDate,
    final int? reminderMinuteOfDay,
    final bool repeatsDaily,
    required final bool isCompleted,
    required final List<SubTaskModel> subtasks,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$TaskModelImpl;
  const _TaskModel._() : super._();

  factory _TaskModel.fromJson(Map<String, dynamic> json) =
      _$TaskModelImpl.fromJson;

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
  List<SubTaskModel> get subtasks;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskModelImplCopyWith<_$TaskModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
