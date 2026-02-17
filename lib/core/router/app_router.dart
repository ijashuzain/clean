import 'package:logit/core/router/route_paths.dart';
import 'package:logit/features/auth/presentation/providers/auth_session_provider/auth_session_provider.dart';
import 'package:logit/features/auth/presentation/providers/onboarding_status_provider/onboarding_status_provider.dart';
import 'package:logit/features/auth/presentation/views/login_view.dart';
import 'package:logit/features/auth/presentation/views/signup_view.dart';
import 'package:logit/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:logit/features/splash/presentation/views/splash_view.dart';
import 'package:logit/features/settings/presentation/views/settings_view.dart';
import 'package:logit/features/task/presentation/views/task_list_view.dart';
import 'package:logit/features/task/presentation/views/task_manage_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final refreshNotifier = ValueNotifier<int>(0);
  ref.onDispose(refreshNotifier.dispose);
  ref.listen(authSessionNotifierProvider, (previous, next) {
    refreshNotifier.value++;
  });
  ref.listen(onboardingStatusNotifierProvider, (previous, next) {
    refreshNotifier.value++;
  });

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: false,
    refreshListenable: refreshNotifier,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: RoutePaths.signup,
        builder: (context, state) => const SignupView(),
      ),
      GoRoute(
        path: RoutePaths.tasks,
        builder: (context, state) => const TaskListView(),
      ),
      GoRoute(
        path: RoutePaths.taskManage,
        builder: (context, state) {
          final taskId = state.uri.queryParameters['id'];
          return TaskManageView(taskId: taskId);
        },
      ),
      GoRoute(
        path: RoutePaths.settings,
        builder: (context, state) => const SettingsView(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authSessionNotifierProvider);
      final onboardingState = ref.read(onboardingStatusNotifierProvider);
      final location = state.matchedLocation;

      final goingSplash = location == RoutePaths.splash;
      final goingOnboarding = location == RoutePaths.onboarding;
      final goingAuth =
          location == RoutePaths.login || location == RoutePaths.signup;
      final goingProtected =
          location == RoutePaths.tasks ||
          location == RoutePaths.taskManage ||
          location == RoutePaths.settings;

      if (!authState.isReady || !onboardingState.isReady) {
        return goingSplash ? null : RoutePaths.splash;
      }

      if (!onboardingState.seen) {
        return goingOnboarding ? null : RoutePaths.onboarding;
      }

      if (goingOnboarding && onboardingState.seen) {
        return authState.isAuthenticated ? RoutePaths.tasks : RoutePaths.login;
      }

      if (authState.isAuthenticated) {
        if (goingAuth || goingSplash) {
          return RoutePaths.tasks;
        }
        return null;
      }

      if (goingProtected) {
        return RoutePaths.login;
      }

      if (goingSplash) {
        return RoutePaths.login;
      }

      return null;
    },
  );
}
