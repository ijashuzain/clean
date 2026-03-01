import 'package:logit/core/failure/failure.dart';
import 'package:logit/core/utils/result/result.dart';
import 'package:logit/core/utils/status/status.dart';
import 'package:logit/features/auth/domain/entities/app_user/app_user.dart';
import 'package:logit/features/auth/domain/repositories/auth_repository.dart';
import 'package:logit/features/auth/domain/usecases/signup_usecase/signup_usecase.dart';
import 'package:logit/features/auth/presentation/providers/auth_session_provider/auth_session_provider.dart';
import 'package:logit/features/auth/presentation/providers/signup_view_provider/signup_view_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('successful signup updates state and session', () async {
    const user = AppUser(id: 'u1', name: 'Ija', email: 'ija@example.com');
    final repository = _FakeAuthRepository(
      signupResult: const Result.success(user),
    );
    final params = SingupParams(
      name: 'Ija',
      email: 'ija@example.com',
      password: 'secret123',
    );

    final container = ProviderContainer(
      overrides: [
        signupUseCaseProvider.overrideWithValue(
          SignupUseCase(authRepository: repository),
        ),
        authSessionNotifierProvider.overrideWith(_FakeAuthSessionNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    await container.read(signupViewProviderProvider.notifier).signup(params);

    final signupState = container.read(signupViewProviderProvider);
    final authState = container.read(authSessionNotifierProvider);
    expect(signupState.signupStatus, const Status.success());
    expect(signupState.user, user);
    expect(authState.isAuthenticated, isTrue);
    expect(authState.user, user);
    expect(repository.signupCallCount, 1);
  });

  test('validation failure does not call repository', () async {
    final repository = _FakeAuthRepository(
      signupResult: const Result.success(AppUser()),
    );
    final params = SingupParams(name: '', email: 'bad-email', password: '123');

    final container = ProviderContainer(
      overrides: [
        signupUseCaseProvider.overrideWithValue(
          SignupUseCase(authRepository: repository),
        ),
        authSessionNotifierProvider.overrideWith(_FakeAuthSessionNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    await container.read(signupViewProviderProvider.notifier).signup(params);

    final signupState = container.read(signupViewProviderProvider);
    expect(signupState.signupStatus, const Status.failure('Name is required'));
    expect(repository.signupCallCount, 0);
  });

  test('repository failure updates signup status with message', () async {
    final repository = _FakeAuthRepository(
      signupResult: Result.failure(
        Failure.clientFailure(
          message: 'An account with this email already exists.',
        ),
      ),
    );
    final params = SingupParams(
      name: 'Ija',
      email: 'ija@example.com',
      password: 'secret123',
    );

    final container = ProviderContainer(
      overrides: [
        signupUseCaseProvider.overrideWithValue(
          SignupUseCase(authRepository: repository),
        ),
        authSessionNotifierProvider.overrideWith(_FakeAuthSessionNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    await container.read(signupViewProviderProvider.notifier).signup(params);

    final signupState = container.read(signupViewProviderProvider);
    expect(
      signupState.signupStatus,
      const Status.failure('An account with this email already exists.'),
    );
    expect(repository.signupCallCount, 1);
  });
}

class _FakeAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isReady: true);
  }
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.signupResult});

  final Result<AppUser> signupResult;
  int signupCallCount = 0;

  @override
  Future<Result<AppUser>> signup(
    String name,
    String email,
    String password,
  ) async {
    signupCallCount++;
    return signupResult;
  }

  @override
  Future<Result<AppUser>> login(String email, String password) async {
    return const Result.success(AppUser());
  }

  @override
  Future<Result<AppUser?>> currentUser() async => const Result.success(null);

  @override
  Future<Result<bool>> hasPin() async => const Result.success(false);

  @override
  Future<Result<void>> setPin(String pin) async => const Result.success(null);

  @override
  Future<Result<bool>> verifyPin(String pin) async =>
      const Result.success(false);

  @override
  Future<Result<void>> logout() async => const Result.success(null);
}
