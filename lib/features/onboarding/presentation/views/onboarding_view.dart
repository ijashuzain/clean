import 'package:logit/core/router/route_paths.dart';
import 'package:logit/core/theme/app_colors.dart';
import 'package:logit/features/auth/presentation/providers/onboarding_status_provider/onboarding_status_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class OnboardingView extends ConsumerWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF1B1B1B), Color(0xFF26241D)]
                : const [Color(0xFFF8F7EF), Color(0xFFF2ECD3)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final maxHeight = constraints.maxHeight;
              final cardHeight = (maxHeight * 0.38).clamp(320.0, 380.0);
              final textColor = isDark ? AppColors.darkText : AppColors.brandText;

              return Stack(
                children: [
                  Positioned(
                    top: maxHeight * 0.08,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/logo.svg',
                        width: maxWidth * 0.22,
                        colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  Positioned(
                    top: maxHeight * 0.22,
                    left: maxWidth * 0.22,
                    child: Transform.rotate(
                      angle: -0.55,
                      child: Column(
                        children: [
                          _line(isDark),
                          const SizedBox(height: 10),
                          _line(isDark),
                          const SizedBox(height: 10),
                          _line(isDark),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Container(
                      height: cardHeight,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : const Color(0xFFF3F3F5),
                        borderRadius: BorderRadius.circular(38),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 62,
                            right: 0,
                            top: -120,
                            child: Image.asset(
                              'assets/images/onboard-illustration.png',
                              fit: BoxFit.contain,
                              height: 250,
                            ),
                          ),
                          Positioned(
                            left: 30,
                            bottom: 146,
                            child: Text(
                              'Manage\nYour\nDaily Tasks',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.16,
                                color: textColor,
                              ),
                            ),
                          ),
                          Positioned(
                            left: maxWidth * 0.45,
                            bottom: 90,
                            child: SvgPicture.asset(
                              'assets/icons/onboarding-scribble-arrow.svg',
                              width: 75,
                              colorFilter: ColorFilter.mode(
                                isDark ? AppColors.darkMutedText : AppColors.brandText,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 28,
                            right: 28,
                            bottom: 24,
                            child: SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await ref.read(onboardingStatusNotifierProvider.notifier).complete();
                                  if (context.mounted) {
                                    context.go(RoutePaths.login);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: isDark ? const Color(0xFF3D3724) : const Color(0xFFEFE7C8),
                                  foregroundColor: textColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                ),
                                child: const Text(
                                  'Start Now',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _line(bool isDark) {
    return Container(
      width: 136,
      height: 1.2,
      color: isDark ? AppColors.darkMutedText.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.45),
    );
  }
}
