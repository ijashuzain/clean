import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logit/core/constants/hive_keys.dart';
import 'package:logit/core/subscription/subscription_feature_flag_provider.dart';
import 'package:logit/features/auth/presentation/providers/auth_session_provider/auth_session_provider.dart';
import 'package:logit/features/auth/presentation/providers/pin_auth_session_provider/pin_auth_session_provider.dart';

@immutable
class SubscriptionAccessState {
  final String activeUserId;
  final bool isSubscribed;
  final bool gateSeenThisSession;

  const SubscriptionAccessState({
    this.activeUserId = '',
    this.isSubscribed = false,
    this.gateSeenThisSession = false,
  });

  SubscriptionAccessState copyWith({
    String? activeUserId,
    bool? isSubscribed,
    bool? gateSeenThisSession,
  }) {
    return SubscriptionAccessState(
      activeUserId: activeUserId ?? this.activeUserId,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      gateSeenThisSession: gateSeenThisSession ?? this.gateSeenThisSession,
    );
  }
}

final subscriptionAccessNotifierProvider =
    StateNotifierProvider<SubscriptionAccessNotifier, SubscriptionAccessState>((
      ref,
    ) {
      final notifier = SubscriptionAccessNotifier(ref);
      ref.listen(authSessionNotifierProvider, (previous, next) {
        final previousUserId = previous?.isAuthenticated == true
            ? previous!.user.id.trim()
            : '';
        final nextUserId = next.isAuthenticated ? next.user.id.trim() : '';
        if (previousUserId != nextUserId) {
          notifier.resetGateForSession();
          unawaited(notifier.reloadForUser(nextUserId));
          return;
        }
        if (!next.isAuthenticated) {
          notifier.resetGateForSession();
        }
      });
      ref.listen(pinAuthSessionNotifierProvider, (previous, next) {
        if (!next.isUnlocked) {
          notifier.resetGateForSession();
        }
      });
      return notifier;
    });

final shouldShowSubscriptionGateProvider = Provider<bool>((ref) {
  final featureEnabled = ref.watch(subscriptionFeatureEnabledProvider);
  final state = ref.watch(subscriptionAccessNotifierProvider);
  return featureEnabled && !state.isSubscribed && !state.gateSeenThisSession;
});

final subscriptionRestrictionsEnabledProvider = Provider<bool>((ref) {
  final featureEnabled = ref.watch(subscriptionFeatureEnabledProvider);
  final state = ref.watch(subscriptionAccessNotifierProvider);
  return featureEnabled && !state.isSubscribed;
});

class SubscriptionPlanLimits {
  static const int monthlyPriceInr = 60;
  static const int freeTasksPerDay = 3;
  static const int freeSubtasksPerTask = 2;
  static const int freeRemindersPerTask = 1;
  static const int freeMaxEndDateDays = 3;
}

class SubscriptionAccessNotifier
    extends StateNotifier<SubscriptionAccessState> {
  final Ref _ref;
  final Box<dynamic> _settingsBox = Hive.box<dynamic>(HiveBoxNames.settings);

  SubscriptionAccessNotifier(this._ref)
    : super(
        SubscriptionAccessState(
          activeUserId: _initialUserId(_ref),
          isSubscribed: _readSubscribedFromStorage(_initialUserId(_ref)),
        ),
      );

  static String _initialUserId(Ref ref) {
    final authState = ref.read(authSessionNotifierProvider);
    if (!authState.isAuthenticated) {
      return '';
    }
    return authState.user.id.trim();
  }

  static String _subscribedKeyForUser(String userId) {
    return '${HiveSettingsKeys.subscribed}_${userId.trim()}';
  }

  static bool _readSubscribedFromStorage(String userId) {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      return false;
    }
    final value = Hive.box<dynamic>(
      HiveBoxNames.settings,
    ).get(_subscribedKeyForUser(normalizedUserId), defaultValue: false);
    return value is bool ? value : false;
  }

  bool get isFeatureEnabled => _ref.read(subscriptionFeatureEnabledProvider);

  bool get shouldShowGate =>
      isFeatureEnabled && !state.isSubscribed && !state.gateSeenThisSession;

  Future<void> setSubscribed(bool subscribed) async {
    final userId = _initialUserId(_ref);
    if (userId.isEmpty) {
      state = state.copyWith(activeUserId: '', isSubscribed: false);
      return;
    }
    await _settingsBox.put(_subscribedKeyForUser(userId), subscribed);
    state = state.copyWith(activeUserId: userId, isSubscribed: subscribed);
  }

  Future<void> reloadForUser(String userId) async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      state = const SubscriptionAccessState();
      return;
    }
    state = state.copyWith(
      activeUserId: normalizedUserId,
      isSubscribed: _readSubscribedFromStorage(normalizedUserId),
      gateSeenThisSession: false,
    );
  }

  void markGateSeen() {
    state = state.copyWith(gateSeenThisSession: true);
  }

  void resetGateForSession() {
    if (!state.gateSeenThisSession) {
      return;
    }
    state = state.copyWith(gateSeenThisSession: false);
  }
}
