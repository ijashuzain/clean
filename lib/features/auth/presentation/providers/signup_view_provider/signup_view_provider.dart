import 'package:logit/core/utils/status/status.dart';
import 'package:logit/features/auth/domain/entities/app_user/app_user.dart';
import 'package:logit/features/auth/domain/usecases/signup_usecase/signup_usecase.dart';
import 'package:logit/features/auth/presentation/providers/auth_session_provider/auth_session_provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'signup_view_provider.freezed.dart';
part 'signup_view_provider.g.dart';

@freezed
class SignupViewState with _$SignupViewState {
  const factory SignupViewState({
    @Default(Status.initial()) Status signupStatus,
    @Default(AppUser()) AppUser user,
  }) = _SignupViewState;
}

@riverpod
class SignupViewProvider extends _$SignupViewProvider {
  @override
  SignupViewState build() {
    return const SignupViewState();
  }

  Future<void> signup(SingupParams params) async {
    state = state.copyWith(signupStatus: Status.loading());
    final result = await ref.read(signupUseCaseProvider).call(params);
    result.when(
      success: (user) {
        state = state.copyWith(signupStatus: Status.success(), user: user);
        ref.read(authSessionNotifierProvider.notifier).setSession(user);
      },
      failure: (failure) {
        state = state.copyWith(signupStatus: Status.failure(failure.message));
      },
    );
  }
}
