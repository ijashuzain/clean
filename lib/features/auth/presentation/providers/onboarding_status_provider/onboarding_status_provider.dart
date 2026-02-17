import 'package:logit/core/constants/hive_keys.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_status_provider.freezed.dart';
part 'onboarding_status_provider.g.dart';

@freezed
class OnboardingStatusState with _$OnboardingStatusState {
  const factory OnboardingStatusState({
    @Default(false) bool isReady,
    @Default(false) bool seen,
  }) = _OnboardingStatusState;
}

@riverpod
class OnboardingStatusNotifier extends _$OnboardingStatusNotifier {
  @override
  OnboardingStatusState build() {
    final box = Hive.box<dynamic>(HiveBoxNames.settings);
    final seen =
        box.get(HiveSettingsKeys.onboardingSeen, defaultValue: false) as bool;
    return OnboardingStatusState(isReady: true, seen: seen);
  }

  Future<void> complete() async {
    await Hive.box<dynamic>(
      HiveBoxNames.settings,
    ).put(HiveSettingsKeys.onboardingSeen, true);
    state = state.copyWith(seen: true, isReady: true);
  }
}
