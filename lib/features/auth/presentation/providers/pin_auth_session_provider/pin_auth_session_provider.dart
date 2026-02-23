import 'package:logit/core/utils/status/status.dart';
import 'package:logit/features/auth/domain/usecases/has_pin_usecase/has_pin_usecase.dart';
import 'package:logit/features/auth/domain/usecases/set_pin_usecase/set_pin_usecase.dart';
import 'package:logit/features/auth/domain/usecases/verify_pin_usecase/verify_pin_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class PinAuthSessionState {
  final bool isReady;
  final bool hasPin;
  final bool isUnlocked;
  final Status actionStatus;
  final String message;

  const PinAuthSessionState({
    this.isReady = false,
    this.hasPin = false,
    this.isUnlocked = false,
    this.actionStatus = const Status.initial(),
    this.message = '',
  });

  PinAuthSessionState copyWith({
    bool? isReady,
    bool? hasPin,
    bool? isUnlocked,
    Status? actionStatus,
    String? message,
  }) {
    return PinAuthSessionState(
      isReady: isReady ?? this.isReady,
      hasPin: hasPin ?? this.hasPin,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      actionStatus: actionStatus ?? this.actionStatus,
      message: message ?? this.message,
    );
  }
}

final pinAuthSessionNotifierProvider =
    StateNotifierProvider<PinAuthSessionNotifier, PinAuthSessionState>((ref) {
      return PinAuthSessionNotifier(ref);
    });

class PinAuthSessionNotifier extends StateNotifier<PinAuthSessionState> {
  final Ref _ref;

  PinAuthSessionNotifier(this._ref) : super(const PinAuthSessionState()) {
    Future.microtask(_restore);
  }

  Future<void> _restore() async {
    final result = await _ref.read(hasPinUseCaseProvider).call();
    result.when(
      success: (hasPin) {
        state = state.copyWith(
          isReady: true,
          hasPin: hasPin,
          isUnlocked: false,
          actionStatus: const Status.initial(),
          message: '',
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isReady: true,
          hasPin: false,
          isUnlocked: false,
          actionStatus: Status.failure(failure.message),
          message: failure.message,
        );
      },
    );
  }

  Future<bool> registerPin(String pin) async {
    if (!_isValidPin(pin)) {
      final message = 'PIN must be exactly 4 digits';
      state = state.copyWith(
        actionStatus: Status.failure(message),
        message: message,
      );
      return false;
    }

    state = state.copyWith(actionStatus: const Status.loading(), message: '');
    final result = await _ref
        .read(setPinUseCaseProvider)
        .call(SetPinParams(pin: pin));
    return result.when(
      success: (_) {
        state = state.copyWith(
          isReady: true,
          hasPin: true,
          isUnlocked: true,
          actionStatus: const Status.success(),
          message: '',
        );
        return true;
      },
      failure: (failure) {
        state = state.copyWith(
          actionStatus: Status.failure(failure.message),
          message: failure.message,
        );
        return false;
      },
    );
  }

  Future<bool> unlockWithPin(String pin) async {
    if (!_isValidPin(pin)) {
      final message = 'PIN must be exactly 4 digits';
      state = state.copyWith(
        actionStatus: Status.failure(message),
        message: message,
      );
      return false;
    }

    state = state.copyWith(actionStatus: const Status.loading(), message: '');
    final result = await _ref
        .read(verifyPinUseCaseProvider)
        .call(VerifyPinParams(pin: pin));
    return result.when(
      success: (isValid) {
        if (!isValid) {
          final message = 'Incorrect PIN';
          state = state.copyWith(
            isUnlocked: false,
            actionStatus: Status.failure(message),
            message: message,
          );
          return false;
        }
        state = state.copyWith(
          isUnlocked: true,
          actionStatus: const Status.success(),
          message: '',
        );
        return true;
      },
      failure: (failure) {
        state = state.copyWith(
          isUnlocked: false,
          actionStatus: Status.failure(failure.message),
          message: failure.message,
        );
        return false;
      },
    );
  }

  void lock() {
    state = state.copyWith(
      isUnlocked: false,
      actionStatus: const Status.initial(),
      message: '',
    );
  }

  Future<void> refresh() async {
    await _restore();
  }

  bool _isValidPin(String pin) {
    return RegExp(r'^\d{4}$').hasMatch(pin.trim());
  }
}
