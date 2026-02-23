import 'package:logit/core/router/route_paths.dart';
import 'package:logit/features/auth/presentation/providers/onboarding_status_provider/onboarding_status_provider.dart';
import 'package:logit/features/auth/presentation/providers/pin_auth_session_provider/pin_auth_session_provider.dart';
import 'package:logit/features/auth/presentation/views/login_view.dart';
import 'package:logit/features/auth/presentation/views/pin_auth_view.dart';
import 'package:logit/features/auth/presentation/views/signup_view.dart';
import 'package:logit/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:logit/features/settings/presentation/views/change_pin_view.dart';
import 'package:logit/features/splash/presentation/views/splash_view.dart';
import 'package:logit/features/settings/presentation/views/settings_view.dart';
import 'package:logit/features/task/presentation/views/task_list_view.dart';
import 'package:logit/features/task/presentation/views/task_manage_view.dart';
import 'package:logit/features/task/presentation/views/task_reminders_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final refreshNotifier = ValueNotifier<int>(0);
  ref.onDispose(refreshNotifier.dispose);
  ref.listen(onboardingStatusNotifierProvider, (previous, next) {
    refreshNotifier.value++;
  });
  ref.listen(pinAuthSessionNotifierProvider, (previous, next) {
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
        path: RoutePaths.pinAuth,
        builder: (context, state) => const PinAuthView(),
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
        path: RoutePaths.taskReminders,
        builder: (context, state) {
          final args = state.extra;
          if (args is! TaskRemindersArgs) {
            return const TaskListView();
          }
          return TaskRemindersView(args: args);
        },
      ),
      GoRoute(
        path: RoutePaths.settings,
        builder: (context, state) => const SettingsView(),
      ),
      GoRoute(
        path: RoutePaths.changePin,
        builder: (context, state) => const ChangePinView(),
      ),
    ],
    redirect: (context, state) {
      final onboardingState = ref.read(onboardingStatusNotifierProvider);
      final pinState = ref.read(pinAuthSessionNotifierProvider);
      final location = state.matchedLocation;

      final goingSplash = location == RoutePaths.splash;
      final goingOnboarding = location == RoutePaths.onboarding;
      final goingPin = location == RoutePaths.pinAuth;
      final goingAuth =
          location == RoutePaths.login || location == RoutePaths.signup;
      final goingProtected =
          location == RoutePaths.tasks ||
          location == RoutePaths.taskManage ||
          location == RoutePaths.taskReminders ||
          location == RoutePaths.settings ||
          location == RoutePaths.changePin;

      if (!pinState.isReady || !onboardingState.isReady) {
        return goingSplash ? null : RoutePaths.splash;
      }

      if (!onboardingState.seen) {
        return goingOnboarding ? null : RoutePaths.onboarding;
      }

      if (!pinState.hasPin) {
        return goingPin ? null : RoutePaths.pinAuth;
      }

      if (!pinState.isUnlocked) {
        return goingPin ? null : RoutePaths.pinAuth;
      }

      if (goingSplash || goingOnboarding || goingPin || goingAuth) {
        return RoutePaths.tasks;
      }

      if (goingProtected) {
        return null;
      }

      return null;
    },
  );
}
