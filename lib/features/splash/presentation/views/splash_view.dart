import 'package:logit/core/theme/app_colors.dart';
import 'package:logit/core/widgets/brand_logo.dart';
import 'package:flutter/material.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor,
              AppColors.accentGold.withValues(alpha: 0.22),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BrandLogo(),
              SizedBox(height: 24),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
