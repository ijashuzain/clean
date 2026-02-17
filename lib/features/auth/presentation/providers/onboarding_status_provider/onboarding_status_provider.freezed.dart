// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_status_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OnboardingStatusState {
  bool get isReady => throw _privateConstructorUsedError;
  bool get seen => throw _privateConstructorUsedError;

  /// Create a copy of OnboardingStatusState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnboardingStatusStateCopyWith<OnboardingStatusState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingStatusStateCopyWith<$Res> {
  factory $OnboardingStatusStateCopyWith(
    OnboardingStatusState value,
    $Res Function(OnboardingStatusState) then,
  ) = _$OnboardingStatusStateCopyWithImpl<$Res, OnboardingStatusState>;
  @useResult
  $Res call({bool isReady, bool seen});
}

/// @nodoc
class _$OnboardingStatusStateCopyWithImpl<
  $Res,
  $Val extends OnboardingStatusState
>
    implements $OnboardingStatusStateCopyWith<$Res> {
  _$OnboardingStatusStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnboardingStatusState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? isReady = null, Object? seen = null}) {
    return _then(
      _value.copyWith(
            isReady: null == isReady
                ? _value.isReady
                : isReady // ignore: cast_nullable_to_non_nullable
                      as bool,
            seen: null == seen
                ? _value.seen
                : seen // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OnboardingStatusStateImplCopyWith<$Res>
    implements $OnboardingStatusStateCopyWith<$Res> {
  factory _$$OnboardingStatusStateImplCopyWith(
    _$OnboardingStatusStateImpl value,
    $Res Function(_$OnboardingStatusStateImpl) then,
  ) = __$$OnboardingStatusStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isReady, bool seen});
}

/// @nodoc
class __$$OnboardingStatusStateImplCopyWithImpl<$Res>
    extends
        _$OnboardingStatusStateCopyWithImpl<$Res, _$OnboardingStatusStateImpl>
    implements _$$OnboardingStatusStateImplCopyWith<$Res> {
  __$$OnboardingStatusStateImplCopyWithImpl(
    _$OnboardingStatusStateImpl _value,
    $Res Function(_$OnboardingStatusStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnboardingStatusState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? isReady = null, Object? seen = null}) {
    return _then(
      _$OnboardingStatusStateImpl(
        isReady: null == isReady
            ? _value.isReady
            : isReady // ignore: cast_nullable_to_non_nullable
                  as bool,
        seen: null == seen
            ? _value.seen
            : seen // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$OnboardingStatusStateImpl implements _OnboardingStatusState {
  const _$OnboardingStatusStateImpl({this.isReady = false, this.seen = false});

  @override
  @JsonKey()
  final bool isReady;
  @override
  @JsonKey()
  final bool seen;

  @override
  String toString() {
    return 'OnboardingStatusState(isReady: $isReady, seen: $seen)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingStatusStateImpl &&
            (identical(other.isReady, isReady) || other.isReady == isReady) &&
            (identical(other.seen, seen) || other.seen == seen));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isReady, seen);

  /// Create a copy of OnboardingStatusState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingStatusStateImplCopyWith<_$OnboardingStatusStateImpl>
  get copyWith =>
      __$$OnboardingStatusStateImplCopyWithImpl<_$OnboardingStatusStateImpl>(
        this,
        _$identity,
      );
}

abstract class _OnboardingStatusState implements OnboardingStatusState {
  const factory _OnboardingStatusState({final bool isReady, final bool seen}) =
      _$OnboardingStatusStateImpl;

  @override
  bool get isReady;
  @override
  bool get seen;

  /// Create a copy of OnboardingStatusState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnboardingStatusStateImplCopyWith<_$OnboardingStatusStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
