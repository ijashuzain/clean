import 'package:logit/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final double fontSize;

  const BrandLogo({super.key, this.fontSize = 42});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkText
        : AppColors.brandText;

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: -0.5,
        ),
        children: const [
          TextSpan(text: 'L'),
          TextSpan(text: 'o'),
          TextSpan(text: 'g'),
          TextSpan(text: 'I'),
          TextSpan(text: 't'),
        ],
      ),
    );
  }
}
