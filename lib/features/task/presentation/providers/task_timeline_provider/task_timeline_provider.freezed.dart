// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_timeline_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TaskTimelineState {
  DateTime get selectedDate => throw _privateConstructorUsedError;
  List<Task> get tasks => throw _privateConstructorUsedError;
  Map<String, List<String>> get weekEmojiMap =>
      throw _privateConstructorUsedError;
  Status get taskStatus => throw _privateConstructorUsedError;

  /// Create a copy of TaskTimelineState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskTimelineStateCopyWith<TaskTimelineState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskTimelineStateCopyWith<$Res> {
  factory $TaskTimelineStateCopyWith(
    TaskTimelineState value,
    $Res Function(TaskTimelineState) then,
  ) = _$TaskTimelineStateCopyWithImpl<$Res, TaskTimelineState>;
  @useResult
  $Res call({
    DateTime selectedDate,
    List<Task> tasks,
    Map<String, List<String>> weekEmojiMap,
    Status taskStatus,
  });

  $StatusCopyWith<$Res> get taskStatus;
}

/// @nodoc
class _$TaskTimelineStateCopyWithImpl<$Res, $Val extends TaskTimelineState>
    implements $TaskTimelineStateCopyWith<$Res> {
  _$TaskTimelineStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskTimelineState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedDate = null,
    Object? tasks = null,
    Object? weekEmojiMap = null,
    Object? taskStatus = null,
  }) {
    return _then(
      _value.copyWith(
            selectedDate: null == selectedDate
                ? _value.selectedDate
                : selectedDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            tasks: null == tasks
                ? _value.tasks
                : tasks // ignore: cast_nullable_to_non_nullable
                      as List<Task>,
            weekEmojiMap: null == weekEmojiMap
                ? _value.weekEmojiMap
                : weekEmojiMap // ignore: cast_nullable_to_non_nullable
                      as Map<String, List<String>>,
            taskStatus: null == taskStatus
                ? _value.taskStatus
                : taskStatus // ignore: cast_nullable_to_non_nullable
                      as Status,
          )
          as $Val,
    );
  }

  /// Create a copy of TaskTimelineState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StatusCopyWith<$Res> get taskStatus {
    return $StatusCopyWith<$Res>(_value.taskStatus, (value) {
      return _then(_value.copyWith(taskStatus: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TaskTimelineStateImplCopyWith<$Res>
    implements $TaskTimelineStateCopyWith<$Res> {
  factory _$$TaskTimelineStateImplCopyWith(
    _$TaskTimelineStateImpl value,
    $Res Function(_$TaskTimelineStateImpl) then,
  ) = __$$TaskTimelineStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime selectedDate,
    List<Task> tasks,
    Map<String, List<String>> weekEmojiMap,
    Status taskStatus,
  });

  @override
  $StatusCopyWith<$Res> get taskStatus;
}

/// @nodoc
class __$$TaskTimelineStateImplCopyWithImpl<$Res>
    extends _$TaskTimelineStateCopyWithImpl<$Res, _$TaskTimelineStateImpl>
    implements _$$TaskTimelineStateImplCopyWith<$Res> {
  __$$TaskTimelineStateImplCopyWithImpl(
    _$TaskTimelineStateImpl _value,
    $Res Function(_$TaskTimelineStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaskTimelineState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedDate = null,
    Object? tasks = null,
    Object? weekEmojiMap = null,
    Object? taskStatus = null,
  }) {
    return _then(
      _$TaskTimelineStateImpl(
        selectedDate: null == selectedDate
            ? _value.selectedDate
            : selectedDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        tasks: null == tasks
            ? _value._tasks
            : tasks // ignore: cast_nullable_to_non_nullable
                  as List<Task>,
        weekEmojiMap: null == weekEmojiMap
            ? _value._weekEmojiMap
            : weekEmojiMap // ignore: cast_nullable_to_non_nullable
                  as Map<String, List<String>>,
        taskStatus: null == taskStatus
            ? _value.taskStatus
            : taskStatus // ignore: cast_nullable_to_non_nullable
                  as Status,
      ),
    );
  }
}

/// @nodoc

class _$TaskTimelineStateImpl implements _TaskTimelineState {
  const _$TaskTimelineStateImpl({
    required this.selectedDate,
    final List<Task> tasks = const <Task>[],
    final Map<String, List<String>> weekEmojiMap =
        const <String, List<String>>{},
    this.taskStatus = const Status.initial(),
  }) : _tasks = tasks,
       _weekEmojiMap = weekEmojiMap;

  @override
  final DateTime selectedDate;
  final List<Task> _tasks;
  @override
  @JsonKey()
  List<Task> get tasks {
    if (_tasks is EqualUnmodifiableListView) return _tasks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tasks);
  }

  final Map<String, List<String>> _weekEmojiMap;
  @override
  @JsonKey()
  Map<String, List<String>> get weekEmojiMap {
    if (_weekEmojiMap is EqualUnmodifiableMapView) return _weekEmojiMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_weekEmojiMap);
  }

  @override
  @JsonKey()
  final Status taskStatus;

  @override
  String toString() {
    return 'TaskTimelineState(selectedDate: $selectedDate, tasks: $tasks, weekEmojiMap: $weekEmojiMap, taskStatus: $taskStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskTimelineStateImpl &&
            (identical(other.selectedDate, selectedDate) ||
                other.selectedDate == selectedDate) &&
            const DeepCollectionEquality().equals(other._tasks, _tasks) &&
            const DeepCollectionEquality().equals(
              other._weekEmojiMap,
              _weekEmojiMap,
            ) &&
            (identical(other.taskStatus, taskStatus) ||
                other.taskStatus == taskStatus));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    selectedDate,
    const DeepCollectionEquality().hash(_tasks),
    const DeepCollectionEquality().hash(_weekEmojiMap),
    taskStatus,
  );

  /// Create a copy of TaskTimelineState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskTimelineStateImplCopyWith<_$TaskTimelineStateImpl> get copyWith =>
      __$$TaskTimelineStateImplCopyWithImpl<_$TaskTimelineStateImpl>(
        this,
        _$identity,
      );
}

abstract class _TaskTimelineState implements TaskTimelineState {
  const factory _TaskTimelineState({
    required final DateTime selectedDate,
    final List<Task> tasks,
    final Map<String, List<String>> weekEmojiMap,
    final Status taskStatus,
  }) = _$TaskTimelineStateImpl;

  @override
  DateTime get selectedDate;
  @override
  List<Task> get tasks;
  @override
  Map<String, List<String>> get weekEmojiMap;
  @override
  Status get taskStatus;

  /// Create a copy of TaskTimelineState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskTimelineStateImplCopyWith<_$TaskTimelineStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
