import 'package:logit/core/constants/hive_keys.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_provider.g.dart';

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeModeOption build() {
    final box = Hive.box<dynamic>(HiveBoxNames.settings);
    final value =
        box.get(
              HiveSettingsKeys.themeMode,
              defaultValue: ThemeModeOption.system.name,
            )
            as String;
    return ThemeModeOption.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeModeOption.system,
    );
  }

  Future<void> setMode(ThemeModeOption mode) async {
    await Hive.box<dynamic>(
      HiveBoxNames.settings,
    ).put(HiveSettingsKeys.themeMode, mode.name);
    state = mode;
  }

  Future<void> toggle() async {
    if (state == ThemeModeOption.light) {
      await setMode(ThemeModeOption.dark);
      return;
    }
    await setMode(ThemeModeOption.light);
  }
}

enum ThemeModeOption { system, light, dark }
