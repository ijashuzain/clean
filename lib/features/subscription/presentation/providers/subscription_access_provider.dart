import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logit/core/constants/hive_keys.dart';
import 'package:logit/core/subscription/subscription_feature_flag_provider.dart';
import 'package:logit/features/auth/presentation/providers/auth_session_provider/auth_session_provider.dart';
import 'package:logit/features/auth/presentation/providers/pin_auth_session_provider/pin_auth_session_provider.dart';

@immutable
class SubscriptionAccessState {
  final bool isSubscribed;
  final bool gateSeenThisSession;

  const SubscriptionAccessState({
    this.isSubscribed = false,
    this.gateSeenThisSession = false,
  });

  SubscriptionAccessState copyWith({
    bool? isSubscribed,
    bool? gateSeenThisSession,
  }) {
    return SubscriptionAccessState(
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
        SubscriptionAccessState(isSubscribed: _readSubscribedFromStorage()),
      );

  static bool _readSubscribedFromStorage() {
    return Hive.box<dynamic>(
          HiveBoxNames.settings,
        ).get(HiveSettingsKeys.subscribed, defaultValue: false)
        as bool;
  }

  bool get isFeatureEnabled => _ref.read(subscriptionFeatureEnabledProvider);

  bool get shouldShowGate =>
      isFeatureEnabled && !state.isSubscribed && !state.gateSeenThisSession;

  Future<void> setSubscribed(bool subscribed) async {
    await _settingsBox.put(HiveSettingsKeys.subscribed, subscribed);
    state = state.copyWith(isSubscribed: subscribed);
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
