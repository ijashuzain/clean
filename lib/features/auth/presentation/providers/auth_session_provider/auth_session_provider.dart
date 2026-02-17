import 'package:logit/features/auth/domain/entities/app_user/app_user.dart';
import 'package:logit/features/auth/domain/usecases/get_current_user_usecase/get_current_user_usecase.dart';
import 'package:logit/features/auth/domain/usecases/logout_usecase/logout_usecase.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_session_provider.freezed.dart';
part 'auth_session_provider.g.dart';

@freezed
class AuthSessionState with _$AuthSessionState {
  const factory AuthSessionState({
    @Default(false) bool isReady,
    @Default(false) bool isAuthenticated,
    @Default(AppUser()) AppUser user,
  }) = _AuthSessionState;
}

@riverpod
class AuthSessionNotifier extends _$AuthSessionNotifier {
  @override
  AuthSessionState build() {
    Future.microtask(_restoreSession);
    return const AuthSessionState();
  }

  Future<void> _restoreSession() async {
    final result = await ref.read(getCurrentUserUseCaseProvider).call();
    result.when(
      success: (user) {
        state = state.copyWith(
          isReady: true,
          isAuthenticated: user != null,
          user: user ?? const AppUser(),
        );
      },
      failure: (_) {
        state = state.copyWith(
          isReady: true,
          isAuthenticated: false,
          user: const AppUser(),
        );
      },
    );
  }

  void setSession(AppUser user) {
    state = state.copyWith(isReady: true, isAuthenticated: true, user: user);
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider).call();
    state = state.copyWith(
      isReady: true,
      isAuthenticated: false,
      user: const AppUser(),
    );
  }
}
