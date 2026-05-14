import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';

class FilterPillWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final int? unreadCount; // Optional unread count to display on the pill
  final VoidCallback onTap;

  const FilterPillWidget({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? kPrimary
              : isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? kPrimary
                : isDark
                ? Colors.white.withValues(alpha: 0.15)
                : const Color(0xFFCBD5E1),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kPrimary.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextStyles.buttonLabel(
                color: isSelected
                    ? Colors.white
                    : isDark
                    ? Colors.white70
                    : const Color(0xFF64748B),
              ),
            ),
            //count all or unread
            if (unreadCount != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.9)
                      : isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : const Color(0xFFCBD5E1).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: TextStyle(
                    color: isSelected
                        ? kPrimary
                        : isDark
                        ? Colors.white70
                        : const Color(0xFF64748B),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
