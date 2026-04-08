import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';

class TaskDetailStatusPriorityRow extends StatelessWidget {
  const TaskDetailStatusPriorityRow({
    super.key,
    required this.task,
    required this.isDark,
  });

  final TaskItem task;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final statusColor = task.status.color;
    final priorityColor = task.priority.color;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withValues(alpha: 0.35)),
          ),
          child: Text(
            task.status.localizedName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: priorityColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          task.priority.localizedName,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : kTextMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
