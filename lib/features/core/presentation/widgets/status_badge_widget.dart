import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';

/// Reusable status badge pill — color driven by [kStatusColors].
class StatusBadgeWidget extends StatelessWidget {
  const StatusBadgeWidget({
    super.key,
    required this.label,
    required this.isDark,
    this.color,
  });

  final String label;
  final bool isDark;

  /// Override color; falls back to [kStatusColors] lookup, then [kPrimary].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? kStatusColors[label] ?? kPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.subTitle(
          color: c,
        ).copyWith(fontWeight: FontWeight.w600, letterSpacing: kLs(0.2)),
      ),
    );
  }
}
