// ── Shared Dialog Text Field ───────────────────────────────────
import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.isDark,
    this.keyboardType,
    this.onChanged,
    this.maxLines = 1,
    this.prefixIcon,
    this.isRequired = false,
    this.obscureText = false,
    this.suffixIcon,
    this.errorText,
    this.helperText,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isDark;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final IconData? prefixIcon;
  final bool isRequired;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? errorText;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : kTextMuted,
            ),
            children: [
              TextSpan(text: label),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          style: TextStyle(
            color: isDark ? Colors.white : kTextDark,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            errorText: errorText,
            helperText: helperText,
            helperMaxLines: 2,
            helperStyle: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              fontSize: 14,
            ),
            filled: true,
            fillColor: isDark ? kSurfaceDark : kBgLight,
            alignLabelWithHint: maxLines > 1,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(
                    prefixIcon,
                    color: isDark ? Colors.grey[500] : kTextMuted,
                    size: 18,
                  ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kPrimary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
