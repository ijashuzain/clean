import 'package:logit/core/utils/status/status.dart';
import 'package:logit/features/auth/domain/entities/app_user/app_user.dart';
import 'package:logit/features/auth/domain/usecases/login_usecase/login_usecase.dart';
import 'package:logit/features/auth/presentation/providers/auth_session_provider/auth_session_provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_view_provider.freezed.dart';
part 'login_view_provider.g.dart';

@freezed
class LoginViewState with _$LoginViewState {
  const factory LoginViewState({
    @Default(Status.initial()) Status loginStatus,
    @Default(AppUser()) AppUser user,
  }) = _LoginViewState;
}

@riverpod
class LoginViewProvider extends _$LoginViewProvider {
  @override
  LoginViewState build() {
    return const LoginViewState();
  }

  Future<void> login(LoginParams params) async {
    state = state.copyWith(loginStatus: Status.loading());
    final result = await ref.read(loginUseCaseProvider).call(params);
    result.when(
      success: (user) {
        state = state.copyWith(loginStatus: Status.success(), user: user);
        ref.read(authSessionNotifierProvider.notifier).setSession(user);
      },
      failure: (failure) {
        state = state.copyWith(loginStatus: Status.failure(failure.message));
      },
    );
  }
}
