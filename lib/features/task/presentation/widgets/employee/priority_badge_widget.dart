import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
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
            style: AppTextStyles.subTitle(
              color: task.priority.color,
            ).copyWith(fontWeight: FontWeight.w600, letterSpacing: kLs(0.2)),
          ),
        ],
      ),
    );
  }
}
