import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/staff/presentation/controllers/task_controller.dart';

class TaskFilterTab extends StatelessWidget {
  const TaskFilterTab({
    super.key,
    required this.filter,
    required this.count,
    required this.ctrl,
    required this.isDark,
  });

  final String filter;
  final int count;
  final TaskController ctrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final selected = ctrl.filterStatus.value == filter;
    final label = filter == 'InProgress' ? 'In Progress' : filter;

    return GestureDetector(
      onTap: () => ctrl.filterStatus.value = filter,
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
              label,
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
