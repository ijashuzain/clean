import 'dart:io';

import 'package:logit/core/constants/hive_keys.dart';
import 'package:logit/features/auth/presentation/providers/onboarding_status_provider/onboarding_status_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory hiveTempDir;
  late Box<dynamic> settingsBox;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    hiveTempDir = await Directory.systemTemp.createTemp(
      'logit_onboarding_test_',
    );
    Hive.init(hiveTempDir.path);
    settingsBox = await Hive.openBox<dynamic>(HiveBoxNames.settings);
  });

  tearDown(() async {
    await settingsBox.clear();
  });

  tearDownAll(() async {
    await settingsBox.close();
    await Hive.close();
    if (await hiveTempDir.exists()) {
      await hiveTempDir.delete(recursive: true);
    }
  });

  test('build reads default seen = false', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(onboardingStatusNotifierProvider);

    expect(state.isReady, isTrue);
    expect(state.seen, isFalse);
  });

  test('complete marks onboarding seen and persists it', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(onboardingStatusNotifierProvider.notifier).complete();

    final state = container.read(onboardingStatusNotifierProvider);
    expect(state.seen, isTrue);
    expect(settingsBox.get(HiveSettingsKeys.onboardingSeen), isTrue);
  });
}
