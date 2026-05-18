import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/format_date.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';

class TaskCardDateRow extends StatelessWidget {
  const TaskCardDateRow({
    super.key,
    required this.mutedColor,
    required this.startLabel,
    required this.isStartFallback,
    this.dueDate,
  });

  final Color mutedColor;
  final String startLabel;
  final bool isStartFallback;
  final DateTime? dueDate;

  static Color dueDateColor(DateTime? dueDate) {
    if (dueDate == null) return kTextMuted;
    final today = DateTime.now();
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    final diff = due.difference(todayOnly).inDays;
    if (diff < 0) return kHighPriority;
    if (diff <= 2) return kMediumPriority;
    return kTextMuted;
  }

  bool get _isOverdue {
    if (dueDate == null) return false;
    final today = DateTime.now();
    return DateTime(
      dueDate!.year,
      dueDate!.month,
      dueDate!.day,
    ).isBefore(DateTime(today.year, today.month, today.day));
  }

  @override
  Widget build(BuildContext context) {
    final dueDateCol = dueDateColor(dueDate);

    return Row(
      children: [
        Icon(Icons.schedule_rounded, size: 12, color: mutedColor),
        const SizedBox(width: 4),
        Text(
          startLabel,
          style: AppTextStyles.subTitle(
            color: isStartFallback
                ? mutedColor
                : (mutedColor.withValues(alpha: 0.9)),
          ),
        ),
        if (dueDate != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 11,
              color: mutedColor,
            ),
          ),
          if (_isOverdue)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: kHighPriority.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: kHighPriority.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 10,
                    color: kHighPriority,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    formatDate(dueDate!),
                    style: AppTextStyles.subTitle(color: kHighPriority),
                  ),
                ],
              ),
            )
          else
            Text(
              formatDate(dueDate!),
              style: AppTextStyles.subTitle(color: dueDateCol),
            ),
        ],
      ],
    );
  }
}
