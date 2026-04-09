import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';

class DateSectionWidget extends StatelessWidget {
  final String label;
  final bool isFirst;
  final bool isDark;

  const DateSectionWidget({
    required this.label,
    required this.isFirst,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 4 : 14, bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : const Color(0xFFDDD6FE),
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: isDark ? Colors.white60 : const Color(0xFF6C63FF),
                letterSpacing: kLs(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
