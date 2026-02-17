import 'package:logit/core/router/route_paths.dart';
import 'package:logit/core/theme/app_colors.dart';
import 'package:logit/core/widgets/brand_logo.dart';
import 'package:logit/core/widgets/primary_button.dart';
import 'package:logit/features/auth/presentation/providers/onboarding_status_provider/onboarding_status_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingView extends ConsumerWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              const BrandLogo(fontSize: 58),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 210,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: const Icon(Icons.edit_note_rounded, size: 74),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Manage your daily tasks',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Date-wise planning, subtasks, and clean productivity workflows in one place.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: 'Start Now',
                      onPressed: () async {
                        await ref
                            .read(onboardingStatusNotifierProvider.notifier)
                            .complete();
                        if (context.mounted) {
                          context.go(RoutePaths.login);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
