// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'signup_view_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SignupViewState {
  Status get signupStatus => throw _privateConstructorUsedError;
  AppUser get user => throw _privateConstructorUsedError;

  /// Create a copy of SignupViewState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SignupViewStateCopyWith<SignupViewState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SignupViewStateCopyWith<$Res> {
  factory $SignupViewStateCopyWith(
    SignupViewState value,
    $Res Function(SignupViewState) then,
  ) = _$SignupViewStateCopyWithImpl<$Res, SignupViewState>;
  @useResult
  $Res call({Status signupStatus, AppUser user});

  $StatusCopyWith<$Res> get signupStatus;
  $AppUserCopyWith<$Res> get user;
}

/// @nodoc
class _$SignupViewStateCopyWithImpl<$Res, $Val extends SignupViewState>
    implements $SignupViewStateCopyWith<$Res> {
  _$SignupViewStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SignupViewState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? signupStatus = null, Object? user = null}) {
    return _then(
      _value.copyWith(
            signupStatus: null == signupStatus
                ? _value.signupStatus
                : signupStatus // ignore: cast_nullable_to_non_nullable
                      as Status,
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as AppUser,
          )
          as $Val,
    );
  }

  /// Create a copy of SignupViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StatusCopyWith<$Res> get signupStatus {
    return $StatusCopyWith<$Res>(_value.signupStatus, (value) {
      return _then(_value.copyWith(signupStatus: value) as $Val);
    });
  }

  /// Create a copy of SignupViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppUserCopyWith<$Res> get user {
    return $AppUserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SignupViewStateImplCopyWith<$Res>
    implements $SignupViewStateCopyWith<$Res> {
  factory _$$SignupViewStateImplCopyWith(
    _$SignupViewStateImpl value,
    $Res Function(_$SignupViewStateImpl) then,
  ) = __$$SignupViewStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Status signupStatus, AppUser user});

  @override
  $StatusCopyWith<$Res> get signupStatus;
  @override
  $AppUserCopyWith<$Res> get user;
}

/// @nodoc
class __$$SignupViewStateImplCopyWithImpl<$Res>
    extends _$SignupViewStateCopyWithImpl<$Res, _$SignupViewStateImpl>
    implements _$$SignupViewStateImplCopyWith<$Res> {
  __$$SignupViewStateImplCopyWithImpl(
    _$SignupViewStateImpl _value,
    $Res Function(_$SignupViewStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignupViewState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? signupStatus = null, Object? user = null}) {
    return _then(
      _$SignupViewStateImpl(
        signupStatus: null == signupStatus
            ? _value.signupStatus
            : signupStatus // ignore: cast_nullable_to_non_nullable
                  as Status,
        user: null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as AppUser,
      ),
    );
  }
}

/// @nodoc

class _$SignupViewStateImpl implements _SignupViewState {
  _$SignupViewStateImpl({
    this.signupStatus = const Status.initial(),
    this.user = const AppUser(),
  });

  @override
  @JsonKey()
  final Status signupStatus;
  @override
  @JsonKey()
  final AppUser user;

  @override
  String toString() {
    return 'SignupViewState(signupStatus: $signupStatus, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SignupViewStateImpl &&
            (identical(other.signupStatus, signupStatus) ||
                other.signupStatus == signupStatus) &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(runtimeType, signupStatus, user);

  /// Create a copy of SignupViewState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SignupViewStateImplCopyWith<_$SignupViewStateImpl> get copyWith =>
      __$$SignupViewStateImplCopyWithImpl<_$SignupViewStateImpl>(
        this,
        _$identity,
      );
}

abstract class _SignupViewState implements SignupViewState {
  factory _SignupViewState({final Status signupStatus, final AppUser user}) =
      _$SignupViewStateImpl;

  @override
  Status get signupStatus;
  @override
  AppUser get user;

  /// Create a copy of SignupViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SignupViewStateImplCopyWith<_$SignupViewStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
