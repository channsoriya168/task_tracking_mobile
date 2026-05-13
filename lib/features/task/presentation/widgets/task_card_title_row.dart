import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';

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
        // ── Title ───────────────────────────────────────────────
        Text(
          task.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.title(
            color: isDark ? Colors.white : kTextDark,
          ).copyWith(fontWeight: FontWeight.w600),
        ),

        // ── Description ──────────────────────────────────────────
        if ((task.description ?? '').isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            task.description!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.subTitle(color: mutedColor),
          ),
        ],
      ],
    );
  }
}
