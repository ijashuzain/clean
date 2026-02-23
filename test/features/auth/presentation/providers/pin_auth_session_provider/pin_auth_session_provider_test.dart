import 'package:logit/core/utils/result/result.dart';
import 'package:logit/core/utils/status/status.dart';
import 'package:logit/features/auth/domain/entities/app_user/app_user.dart';
import 'package:logit/features/auth/domain/repositories/auth_repository.dart';
import 'package:logit/features/auth/domain/usecases/has_pin_usecase/has_pin_usecase.dart';
import 'package:logit/features/auth/domain/usecases/set_pin_usecase/set_pin_usecase.dart';
import 'package:logit/features/auth/domain/usecases/verify_pin_usecase/verify_pin_usecase.dart';
import 'package:logit/features/auth/presentation/providers/pin_auth_session_provider/pin_auth_session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('restore sets hasPin state from repository', () async {
    final repository = _FakeAuthRepository(
      hasPinResult: const Result.success(true),
    );
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    await _waitUntilReady(container);

    final state = container.read(pinAuthSessionNotifierProvider);
    expect(state.isReady, isTrue);
    expect(state.hasPin, isTrue);
    expect(state.isUnlocked, isFalse);
  });

  test(
    'registerPin rejects invalid pin format before repository call',
    () async {
      final repository = _FakeAuthRepository(
        hasPinResult: const Result.success(false),
      );
      final container = _createContainer(repository);
      addTearDown(container.dispose);

      await _waitUntilReady(container);

      final ok = await container
          .read(pinAuthSessionNotifierProvider.notifier)
          .registerPin('12a4');

      expect(ok, isFalse);
      final state = container.read(pinAuthSessionNotifierProvider);
      expect(
        state.actionStatus,
        const Status.failure('PIN must be exactly 4 digits'),
      );
      expect(repository.setPinCallCount, 0);
    },
  );

  test('registerPin success unlocks and marks hasPin true', () async {
    final repository = _FakeAuthRepository(
      hasPinResult: const Result.success(false),
      setPinResult: const Result.success(null),
    );
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    await _waitUntilReady(container);

    final ok = await container
        .read(pinAuthSessionNotifierProvider.notifier)
        .registerPin('1234');

    expect(ok, isTrue);
    final state = container.read(pinAuthSessionNotifierProvider);
    expect(state.hasPin, isTrue);
    expect(state.isUnlocked, isTrue);
    expect(state.actionStatus, const Status.success());
    expect(repository.setPinCallCount, 1);
  });

  test('unlockWithPin sets failure message for incorrect pin', () async {
    final repository = _FakeAuthRepository(
      hasPinResult: const Result.success(true),
      verifyPinResult: const Result.success(false),
    );
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    await _waitUntilReady(container);

    final ok = await container
        .read(pinAuthSessionNotifierProvider.notifier)
        .unlockWithPin('1234');

    expect(ok, isFalse);
    final state = container.read(pinAuthSessionNotifierProvider);
    expect(state.isUnlocked, isFalse);
    expect(state.actionStatus, const Status.failure('Incorrect PIN'));
    expect(repository.verifyPinCallCount, 1);
  });

  test('unlockWithPin success unlocks session', () async {
    final repository = _FakeAuthRepository(
      hasPinResult: const Result.success(true),
      verifyPinResult: const Result.success(true),
    );
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    await _waitUntilReady(container);

    final ok = await container
        .read(pinAuthSessionNotifierProvider.notifier)
        .unlockWithPin('1234');

    expect(ok, isTrue);
    final state = container.read(pinAuthSessionNotifierProvider);
    expect(state.isUnlocked, isTrue);
    expect(state.actionStatus, const Status.success());
    expect(repository.verifyPinCallCount, 1);
  });

  test('lock resets unlocked status and action status', () async {
    final repository = _FakeAuthRepository(
      hasPinResult: const Result.success(true),
      verifyPinResult: const Result.success(true),
    );
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    await _waitUntilReady(container);
    await container
        .read(pinAuthSessionNotifierProvider.notifier)
        .unlockWithPin('1234');

    container.read(pinAuthSessionNotifierProvider.notifier).lock();

    final state = container.read(pinAuthSessionNotifierProvider);
    expect(state.isUnlocked, isFalse);
    expect(state.actionStatus, const Status.initial());
    expect(state.message, isEmpty);
  });
}

ProviderContainer _createContainer(_FakeAuthRepository repository) {
  return ProviderContainer(
    overrides: [
      hasPinUseCaseProvider.overrideWithValue(
        HasPinUseCase(authRepository: repository),
      ),
      setPinUseCaseProvider.overrideWithValue(
        SetPinUseCase(authRepository: repository),
      ),
      verifyPinUseCaseProvider.overrideWithValue(
        VerifyPinUseCase(authRepository: repository),
      ),
    ],
  );
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.hasPinResult = const Result.success(false),
    this.setPinResult = const Result.success(null),
    this.verifyPinResult = const Result.success(false),
  });

  final Result<bool> hasPinResult;
  final Result<void> setPinResult;
  final Result<bool> verifyPinResult;

  int setPinCallCount = 0;
  int verifyPinCallCount = 0;

  @override
  Future<Result<bool>> hasPin() async => hasPinResult;

  @override
  Future<Result<AppUser>> login(String email, String password) async {
    return const Result.success(AppUser());
  }

  @override
  Future<Result<AppUser>> signup(
    String name,
    String email,
    String password,
  ) async {
    return const Result.success(AppUser());
  }

  @override
  Future<Result<AppUser?>> currentUser() async => const Result.success(null);

  @override
  Future<Result<void>> logout() async => const Result.success(null);

  @override
  Future<Result<void>> setPin(String pin) async {
    setPinCallCount++;
    return setPinResult;
  }

  @override
  Future<Result<bool>> verifyPin(String pin) async {
    verifyPinCallCount++;
    return verifyPinResult;
  }
}

Future<void> _waitUntilReady(ProviderContainer container) async {
  for (var i = 0; i < 100; i++) {
    if (container.read(pinAuthSessionNotifierProvider).isReady) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
  fail('Timed out waiting for PIN session restore');
}
