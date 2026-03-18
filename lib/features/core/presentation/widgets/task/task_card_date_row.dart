import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/helper/format_date.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

class TaskCardDateRow extends StatelessWidget {
  const TaskCardDateRow({
    super.key,
    required this.mutedColor,
    required this.startLabel,
    required this.isStartFallback,
    this.dueDate,
  });

  final Color mutedColor;

  /// Already-formatted start label (startDate or createdAt).
  final String startLabel;

  /// True when startLabel comes from createdAt (rendered italic).
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

  @override
  Widget build(BuildContext context) {
    final dueDateCol = dueDateColor(dueDate);

    return Row(
      children: [
        Icon(Icons.today_rounded, size: 11, color: mutedColor),
        const SizedBox(width: 4),
        Text(
          startLabel,
          style: TextStyle(
            fontSize: 11,
            color: mutedColor,
            fontStyle: isStartFallback ? FontStyle.italic : FontStyle.normal,
          ),
        ),
        if (dueDate != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              Icons.arrow_right_alt_rounded,
              size: 13,
              color: mutedColor,
            ),
          ),
          Icon(
            dueDate!.isBefore(DateTime.now()) ? Icons.event_busy_rounded : Icons.event_outlined,
            size: 11,
            color: dueDateCol,
          ),
          const SizedBox(width: 3),
          Text(
            formatDate(dueDate!),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: dueDateCol,
            ),
          ),
        ],
      ],
    );
  }
}