import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';

class PriorityBadgeWidget extends StatelessWidget {
  const PriorityBadgeWidget({
    super.key,
    required this.task,
    required this.isDark,
  });

  final TaskItem task;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: task.priority.color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: task.priority.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: task.priority.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            task.priority.localizedName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: task.priority.color,
            ),
          ),
        ],
      ),
    );
  }
}
