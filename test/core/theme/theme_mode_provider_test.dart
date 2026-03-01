import 'dart:io';

import 'package:logit/core/constants/hive_keys.dart';
import 'package:logit/core/theme/theme_mode_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory hiveTempDir;
  late Box<dynamic> settingsBox;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    hiveTempDir = await Directory.systemTemp.createTemp('logit_theme_test_');
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

  test('build defaults to system mode', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final mode = container.read(themeModeNotifierProvider);

    expect(mode, ThemeModeOption.system);
  });

  test('setMode updates state and persists value', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(themeModeNotifierProvider.notifier)
        .setMode(ThemeModeOption.dark);

    expect(container.read(themeModeNotifierProvider), ThemeModeOption.dark);
    expect(
      settingsBox.get(HiveSettingsKeys.themeMode),
      ThemeModeOption.dark.name,
    );
  });

  test('toggle switches between light and dark', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(themeModeNotifierProvider.notifier)
        .setMode(ThemeModeOption.light);
    await container.read(themeModeNotifierProvider.notifier).toggle();
    expect(container.read(themeModeNotifierProvider), ThemeModeOption.dark);

    await container.read(themeModeNotifierProvider.notifier).toggle();
    expect(container.read(themeModeNotifierProvider), ThemeModeOption.light);
  });
}
