import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.isDark,
    required this.onChanged,
    this.controller,
    this.hintText = 'search_hint',
    this.padding,
  });

  final bool isDark;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String hintText;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white24 : kTextMuted.withValues(alpha: 0.3),
          ),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: AppTextStyles.title(color: isDark ? Colors.white : kTextDark),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.title(
              color: isDark ? Colors.grey[600] : kTextMuted,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: isDark ? Colors.grey[600] : kTextMuted,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}
