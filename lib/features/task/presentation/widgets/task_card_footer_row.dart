import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/status_badge_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/user_avatar_widget.dart';

class TaskCardFooterRow extends StatelessWidget {
  const TaskCardFooterRow({
    super.key,
    required this.task,
    required this.isDark,
    required this.mutedColor,
    required this.statusColor,
    required this.priorityColor,
  });

  final TaskItem task;
  final bool isDark;
  final Color mutedColor;
  final Color statusColor;
  final Color priorityColor;

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
        const SizedBox(width: 8),

        // ── Priority dot + label ────────────────────────────────
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: priorityColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          task.priority.localizedName,
          style: TextStyle(
            fontSize: 11,
            color: mutedColor,
            fontWeight: FontWeight.w500,
          ),
        ),

        const Spacer(),

        // ── Avatars ─────────────────────────────────────────────
        if (task.assignedToName != null)
          UserAvatarWidget(
            name: task.assignedToName!,
            imageUrl: task.assignedToProfileImageUrl,
            radius: 10,
            showBorder: true,
          ),
        if (task.createdByEmployeeName != null)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: UserAvatarWidget(
              name: task.createdByEmployeeName!,
              imageUrl: task.createdByProfileImageUrl,
              radius: 10,
              color: mutedColor,
              showBorder: true,
            ),
          ),
      ],
    );
  }
}
