// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_view_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$LoginViewState {
  Status get loginStatus => throw _privateConstructorUsedError;
  AppUser get user => throw _privateConstructorUsedError;

  /// Create a copy of LoginViewState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginViewStateCopyWith<LoginViewState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginViewStateCopyWith<$Res> {
  factory $LoginViewStateCopyWith(
    LoginViewState value,
    $Res Function(LoginViewState) then,
  ) = _$LoginViewStateCopyWithImpl<$Res, LoginViewState>;
  @useResult
  $Res call({Status loginStatus, AppUser user});

  $StatusCopyWith<$Res> get loginStatus;
  $AppUserCopyWith<$Res> get user;
}

/// @nodoc
class _$LoginViewStateCopyWithImpl<$Res, $Val extends LoginViewState>
    implements $LoginViewStateCopyWith<$Res> {
  _$LoginViewStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginViewState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? loginStatus = null, Object? user = null}) {
    return _then(
      _value.copyWith(
            loginStatus: null == loginStatus
                ? _value.loginStatus
                : loginStatus // ignore: cast_nullable_to_non_nullable
                      as Status,
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as AppUser,
          )
          as $Val,
    );
  }

  /// Create a copy of LoginViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StatusCopyWith<$Res> get loginStatus {
    return $StatusCopyWith<$Res>(_value.loginStatus, (value) {
      return _then(_value.copyWith(loginStatus: value) as $Val);
    });
  }

  /// Create a copy of LoginViewState
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
abstract class _$$LoginViewStateImplCopyWith<$Res>
    implements $LoginViewStateCopyWith<$Res> {
  factory _$$LoginViewStateImplCopyWith(
    _$LoginViewStateImpl value,
    $Res Function(_$LoginViewStateImpl) then,
  ) = __$$LoginViewStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Status loginStatus, AppUser user});

  @override
  $StatusCopyWith<$Res> get loginStatus;
  @override
  $AppUserCopyWith<$Res> get user;
}

/// @nodoc
class __$$LoginViewStateImplCopyWithImpl<$Res>
    extends _$LoginViewStateCopyWithImpl<$Res, _$LoginViewStateImpl>
    implements _$$LoginViewStateImplCopyWith<$Res> {
  __$$LoginViewStateImplCopyWithImpl(
    _$LoginViewStateImpl _value,
    $Res Function(_$LoginViewStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoginViewState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? loginStatus = null, Object? user = null}) {
    return _then(
      _$LoginViewStateImpl(
        loginStatus: null == loginStatus
            ? _value.loginStatus
            : loginStatus // ignore: cast_nullable_to_non_nullable
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

class _$LoginViewStateImpl implements _LoginViewState {
  const _$LoginViewStateImpl({
    this.loginStatus = const Status.initial(),
    this.user = const AppUser(),
  });

  @override
  @JsonKey()
  final Status loginStatus;
  @override
  @JsonKey()
  final AppUser user;

  @override
  String toString() {
    return 'LoginViewState(loginStatus: $loginStatus, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginViewStateImpl &&
            (identical(other.loginStatus, loginStatus) ||
                other.loginStatus == loginStatus) &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(runtimeType, loginStatus, user);

  /// Create a copy of LoginViewState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginViewStateImplCopyWith<_$LoginViewStateImpl> get copyWith =>
      __$$LoginViewStateImplCopyWithImpl<_$LoginViewStateImpl>(
        this,
        _$identity,
      );
}

abstract class _LoginViewState implements LoginViewState {
  const factory _LoginViewState({
    final Status loginStatus,
    final AppUser user,
  }) = _$LoginViewStateImpl;

  @override
  Status get loginStatus;
  @override
  AppUser get user;

  /// Create a copy of LoginViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginViewStateImplCopyWith<_$LoginViewStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
