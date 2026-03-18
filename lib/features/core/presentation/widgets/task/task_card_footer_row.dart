import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
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
        StatusBadgeWidget(
          label: task.status.name,
          color: statusColor,
          isDark: isDark,
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
          task.priority.name,
          style: TextStyle(
            fontSize: 11,
            color: mutedColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        if ((task.labelName ?? task.groupName) != null)
          _NeutralChip(
            label: task.labelName ?? task.groupName!,
            isDark: isDark,
          ),
        const Spacer(),
        if (task.assignedToName != null)
          UserAvatarWidget(
            name: task.assignedToName!,
            imageUrl: task.assignedToProfileImageUrl,
            radius: 10,
            showBorder: true,
          ),
        if (task.createdByEmployeeName != null)
          UserAvatarWidget(
            name: task.createdByEmployeeName!,
            imageUrl: task.createdByProfileImageUrl,
            radius: 10,
            color: mutedColor,
            showBorder: true,
          ),
      ],
    );
  }
}

// ── Neutral chip ───────────────────────────────────────────────
class _NeutralChip extends StatelessWidget {
  const _NeutralChip({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);
    final fg = isDark ? Colors.white60 : kTextMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: fg),
      ),
    );
  }
}