import 'package:flutter_svg/flutter_svg.dart';
import 'package:logit/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final double fontSize;

  const BrandLogo({super.key, this.fontSize = 42});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark ? AppColors.darkText : AppColors.brandText;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        return Center(
          child: SvgPicture.asset(
            'assets/icons/logo.svg',
            width: maxWidth * 0.15,
            colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
          ),
        );
      },
    );
  }
}
