import 'package:clean_sample/core/utils/status/status.dart';
import 'package:clean_sample/features/auth/domain/entities/app_user/app_user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'signup_view_provider.freezed.dart';
part 'signup_view_provider.g.dart';

@freezed
abstract class SignupViewState with _$SignupViewState {
  factory SignupViewState({
    @Default(Status.initial()) Status signupStatus,
    @Default(AppUser()) AppUser user,
  }) = _SignupViewState;
}

@riverpod
class SignupViewProvider extends _$SignupViewProvider {
  @override
  SignupViewState build() {
    return SignupViewState();
  }
}
