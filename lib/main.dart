import 'package:logit/app/app.dart';
import 'package:logit/core/storage/hive_initializer.dart';
import 'package:logit/core/supabase/supabase_initializer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logit/gen/enviro.gen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Enviro.setEnvironment(EnviroEnvironment.DEFAULT);
  await SupabaseInitializer.initialize();
  await HiveInitializer.initialize();

  runApp(const ProviderScope(child: LogItApp()));
}
