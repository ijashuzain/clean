import 'package:logit/core/failure/failure.dart';
import 'package:logit/core/utils/result/result.dart';
import 'package:logit/features/auth/domain/entities/app_user/app_user.dart';
import 'package:logit/features/auth/domain/repositories/auth_repository.dart';
import 'package:logit/features/auth/domain/usecases/get_current_user_usecase/get_current_user_usecase.dart';
import 'package:logit/features/auth/domain/usecases/logout_usecase/logout_usecase.dart';
import 'package:logit/features/auth/presentation/providers/auth_session_provider/auth_session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('restores authenticated session when current user exists', () async {
    const user = AppUser(id: 'u1', name: 'Ija', email: 'ija@example.com');
    final repository = _FakeAuthRepository(
      currentUserResult: const Result.success(user),
      logoutResult: const Result.success(null),
    );

    final container = ProviderContainer(
      overrides: [
        getCurrentUserUseCaseProvider.overrideWithValue(
          GetCurrentUserUseCase(authRepository: repository),
        ),
        logoutUseCaseProvider.overrideWithValue(
          LogoutUseCase(authRepository: repository),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      authSessionNotifierProvider,
      (previous, next) {},
    );
    addTearDown(subscription.close);

    // Initial state before async restore finishes.
    expect(container.read(authSessionNotifierProvider).isReady, isFalse);

    await _waitUntilReady(container);

    final state = container.read(authSessionNotifierProvider);
    expect(state.isReady, isTrue);
    expect(state.isAuthenticated, isTrue);
    expect(state.user, user);
  });

  test('restore failure ends in unauthenticated ready state', () async {
    final repository = _FakeAuthRepository(
      currentUserResult: Result.failure(
        Failure.cacheFailure(message: 'Unable to restore session'),
      ),
      logoutResult: const Result.success(null),
    );

    final container = ProviderContainer(
      overrides: [
        getCurrentUserUseCaseProvider.overrideWithValue(
          GetCurrentUserUseCase(authRepository: repository),
        ),
        logoutUseCaseProvider.overrideWithValue(
          LogoutUseCase(authRepository: repository),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      authSessionNotifierProvider,
      (previous, next) {},
    );
    addTearDown(subscription.close);

    await _waitUntilReady(container);

    final state = container.read(authSessionNotifierProvider);
    expect(state.isReady, isTrue);
    expect(state.isAuthenticated, isFalse);
    expect(state.user, const AppUser());
  });

  test('logout clears auth state and calls repository logout', () async {
    const user = AppUser(id: 'u1', name: 'Ija', email: 'ija@example.com');
    final repository = _FakeAuthRepository(
      currentUserResult: const Result.success(user),
      logoutResult: const Result.success(null),
    );

    final container = ProviderContainer(
      overrides: [
        getCurrentUserUseCaseProvider.overrideWithValue(
          GetCurrentUserUseCase(authRepository: repository),
        ),
        logoutUseCaseProvider.overrideWithValue(
          LogoutUseCase(authRepository: repository),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      authSessionNotifierProvider,
      (previous, next) {},
    );
    addTearDown(subscription.close);

    await _waitUntilReady(container);

    await container.read(authSessionNotifierProvider.notifier).logout();

    final state = container.read(authSessionNotifierProvider);
    expect(state.isReady, isTrue);
    expect(state.isAuthenticated, isFalse);
    expect(state.user, const AppUser());
    expect(repository.logoutCallCount, 1);
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    required this.currentUserResult,
    required this.logoutResult,
  });

  final Result<AppUser?> currentUserResult;
  final Result<void> logoutResult;
  int logoutCallCount = 0;

  @override
  Future<Result<AppUser?>> currentUser() async => currentUserResult;

  @override
  Future<Result<void>> logout() async {
    logoutCallCount++;
    return logoutResult;
  }

  @override
  Future<Result<bool>> hasPin() async => const Result.success(false);

  @override
  Future<Result<AppUser>> login(String email, String password) async {
    return const Result.success(AppUser());
  }

  @override
  Future<Result<void>> setPin(String pin) async => const Result.success(null);

  @override
  Future<Result<AppUser>> signup(String name, String email, String password) {
    return Future.value(const Result.success(AppUser()));
  }

  @override
  Future<Result<bool>> verifyPin(String pin) async =>
      const Result.success(false);
}

Future<void> _waitUntilReady(ProviderContainer container) async {
  for (var i = 0; i < 100; i++) {
    if (container.read(authSessionNotifierProvider).isReady) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
  fail('Timed out waiting for auth session restore');
}
