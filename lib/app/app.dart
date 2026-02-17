import 'package:logit/core/router/app_router.dart';
import 'package:logit/core/theme/app_theme.dart';
import 'package:logit/core/theme/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogItApp extends ConsumerWidget {
  const LogItApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);

    return MaterialApp.router(
      title: 'LogIt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: switch (themeMode) {
        ThemeModeOption.light => ThemeMode.light,
        ThemeModeOption.dark => ThemeMode.dark,
        ThemeModeOption.system => ThemeMode.system,
      },
      routerConfig: router,
    );
  }
}
