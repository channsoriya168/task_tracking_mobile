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
  });

  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : kTextDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 66,
            endIndent: 16,
            color: isDark
                ? Colors.white.withAlpha(12)
                : Colors.black.withAlpha(8),
          ),
      ],
    );
  }
}