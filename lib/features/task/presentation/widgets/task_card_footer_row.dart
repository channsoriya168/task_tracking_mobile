import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/core/widgets/status_badge_widget.dart';
import 'package:task_tracking_mobile/core/widgets/user_avatar_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/stacked_avatars_widget.dart';

class TaskCardFooterRow extends StatelessWidget {
  const TaskCardFooterRow({
    super.key,
    required this.task,
    required this.isDark,
    required this.mutedColor,
    required this.statusColor,
  });

  final TaskItem task;
  final bool isDark;
  final Color mutedColor;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Status badge ────────────────────────────────────────
        StatusBadgeWidget(
          label: task.status.localizedName,
          color: statusColor,
          isDark: isDark,
        ),

        const Spacer(),

        // ── Stacked avatars ─────────────────────────────────────
        StackedAvatarsWidget(task: task, mutedColor: mutedColor),
      ],
    );
  }
}
