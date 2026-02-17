import 'package:logit/core/constants/hive_keys.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveInitializer {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<dynamic>(HiveBoxNames.auth),
      Hive.openBox<dynamic>(HiveBoxNames.task),
      Hive.openBox<dynamic>(HiveBoxNames.settings),
    ]);
  }
}
