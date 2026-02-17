// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_session_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AuthSessionState {
  bool get isReady => throw _privateConstructorUsedError;
  bool get isAuthenticated => throw _privateConstructorUsedError;
  AppUser get user => throw _privateConstructorUsedError;

  /// Create a copy of AuthSessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthSessionStateCopyWith<AuthSessionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthSessionStateCopyWith<$Res> {
  factory $AuthSessionStateCopyWith(
    AuthSessionState value,
    $Res Function(AuthSessionState) then,
  ) = _$AuthSessionStateCopyWithImpl<$Res, AuthSessionState>;
  @useResult
  $Res call({bool isReady, bool isAuthenticated, AppUser user});

  $AppUserCopyWith<$Res> get user;
}

/// @nodoc
class _$AuthSessionStateCopyWithImpl<$Res, $Val extends AuthSessionState>
    implements $AuthSessionStateCopyWith<$Res> {
  _$AuthSessionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthSessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isReady = null,
    Object? isAuthenticated = null,
    Object? user = null,
  }) {
    return _then(
      _value.copyWith(
            isReady: null == isReady
                ? _value.isReady
                : isReady // ignore: cast_nullable_to_non_nullable
                      as bool,
            isAuthenticated: null == isAuthenticated
                ? _value.isAuthenticated
                : isAuthenticated // ignore: cast_nullable_to_non_nullable
                      as bool,
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as AppUser,
          )
          as $Val,
    );
  }

  /// Create a copy of AuthSessionState
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
abstract class _$$AuthSessionStateImplCopyWith<$Res>
    implements $AuthSessionStateCopyWith<$Res> {
  factory _$$AuthSessionStateImplCopyWith(
    _$AuthSessionStateImpl value,
    $Res Function(_$AuthSessionStateImpl) then,
  ) = __$$AuthSessionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isReady, bool isAuthenticated, AppUser user});

  @override
  $AppUserCopyWith<$Res> get user;
}

/// @nodoc
class __$$AuthSessionStateImplCopyWithImpl<$Res>
    extends _$AuthSessionStateCopyWithImpl<$Res, _$AuthSessionStateImpl>
    implements _$$AuthSessionStateImplCopyWith<$Res> {
  __$$AuthSessionStateImplCopyWithImpl(
    _$AuthSessionStateImpl _value,
    $Res Function(_$AuthSessionStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthSessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isReady = null,
    Object? isAuthenticated = null,
    Object? user = null,
  }) {
    return _then(
      _$AuthSessionStateImpl(
        isReady: null == isReady
            ? _value.isReady
            : isReady // ignore: cast_nullable_to_non_nullable
                  as bool,
        isAuthenticated: null == isAuthenticated
            ? _value.isAuthenticated
            : isAuthenticated // ignore: cast_nullable_to_non_nullable
                  as bool,
        user: null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as AppUser,
      ),
    );
  }
}

/// @nodoc

class _$AuthSessionStateImpl implements _AuthSessionState {
  const _$AuthSessionStateImpl({
    this.isReady = false,
    this.isAuthenticated = false,
    this.user = const AppUser(),
  });

  @override
  @JsonKey()
  final bool isReady;
  @override
  @JsonKey()
  final bool isAuthenticated;
  @override
  @JsonKey()
  final AppUser user;

  @override
  String toString() {
    return 'AuthSessionState(isReady: $isReady, isAuthenticated: $isAuthenticated, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthSessionStateImpl &&
            (identical(other.isReady, isReady) || other.isReady == isReady) &&
            (identical(other.isAuthenticated, isAuthenticated) ||
                other.isAuthenticated == isAuthenticated) &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isReady, isAuthenticated, user);

  /// Create a copy of AuthSessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthSessionStateImplCopyWith<_$AuthSessionStateImpl> get copyWith =>
      __$$AuthSessionStateImplCopyWithImpl<_$AuthSessionStateImpl>(
        this,
        _$identity,
      );
}

abstract class _AuthSessionState implements AuthSessionState {
  const factory _AuthSessionState({
    final bool isReady,
    final bool isAuthenticated,
    final AppUser user,
  }) = _$AuthSessionStateImpl;

  @override
  bool get isReady;
  @override
  bool get isAuthenticated;
  @override
  AppUser get user;

  /// Create a copy of AuthSessionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthSessionStateImplCopyWith<_$AuthSessionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
