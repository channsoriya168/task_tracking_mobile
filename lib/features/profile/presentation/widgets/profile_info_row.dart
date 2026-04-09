import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';

class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({
    super.key,
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.showDivider,
    // label kept for API compatibility but not displayed
    this.label = '',
  });

  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String value;
  final bool showDivider;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 0,
            endIndent: 0,
            color: isDark
                ? Colors.white.withAlpha(10)
                : Colors.grey.shade200,
          ),
      ],
    );
  }
}
