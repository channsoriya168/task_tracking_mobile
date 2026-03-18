import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';

class TaskCardTitleRow extends StatelessWidget {
  const TaskCardTitleRow({
    super.key,
    required this.task,
    required this.isDark,
    required this.mutedColor,
  });

  final TaskItem task;
  final bool isDark;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : kTextDark,
            letterSpacing: -0.1,
          ),
        ),
        if ((task.description ?? '').isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            task.description!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: mutedColor,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}