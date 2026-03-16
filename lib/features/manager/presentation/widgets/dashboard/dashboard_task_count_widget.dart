import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

class DashboardTaskCountWidget extends StatelessWidget {
  const DashboardTaskCountWidget({
    super.key,
    required this.count,
    required this.isDark,
    this.hasDateFilter = false,
    this.onClearDate,
  });

  final int count;
  final bool isDark;
  final bool hasDateFilter;
  final VoidCallback? onClearDate;

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDark ? Colors.white38 : kTextMuted;
    final textColor = isDark ? Colors.white : kTextDark;

    return Row(
      children: [
        Text(
          'Tasks',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: kPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kPrimary,
            ),
          ),
        ),
        if (hasDateFilter) ...[
          const Spacer(),
          GestureDetector(
            onTap: onClearDate,
            child: Row(
              children: [
                Icon(Icons.close_rounded, size: 13, color: mutedColor),
                const SizedBox(width: 3),
                Text(
                  'Clear date',
                  style: TextStyle(fontSize: 12, color: mutedColor),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}