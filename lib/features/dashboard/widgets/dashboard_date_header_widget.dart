import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';

class DashboardDateHeaderWidget extends StatelessWidget {
  const DashboardDateHeaderWidget({
    super.key,
    required this.label,
    required this.isDark,
  });

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isSpecial = label == 'Today' || label == 'Yesterday';
    final labelColor =
        isSpecial ? kPrimary : (isDark ? Colors.white38 : kTextMuted);

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSpecial ? FontWeight.w700 : FontWeight.w600,
              color: labelColor,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(
              height: 1,
              thickness: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
        ],
      ),
    );
  }
}