import 'package:logit/app/app.dart';
import 'package:logit/core/storage/hive_initializer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveInitializer.initialize();

  runApp(const ProviderScope(child: LogItApp()));
}
