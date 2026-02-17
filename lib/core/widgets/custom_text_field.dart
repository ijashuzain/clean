import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final int maxLines;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.suffixIcon,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedKeyboardType =
        maxLines > 1 &&
            (keyboardType == TextInputType.text ||
                textInputAction == TextInputAction.newline)
        ? TextInputType.multiline
        : keyboardType;
    final colors = Theme.of(context).colorScheme;
    final hintColor = Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: resolvedKeyboardType,
          maxLines: maxLines,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
