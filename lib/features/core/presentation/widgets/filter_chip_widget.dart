import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

class FilterChipWidget extends StatelessWidget {
  const FilterChipWidget({
    required this.isDark,
    required this.filter,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final bool isDark;
  final String filter;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: kButtonPaddingSmall,
        decoration: BoxDecoration(
          color: selected ? kTextDark : (isDark ? kCardDark : Colors.white),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filter,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white54 : kTextMuted),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: kItemSpacingSmall,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.2)
                    : kPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : kPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
