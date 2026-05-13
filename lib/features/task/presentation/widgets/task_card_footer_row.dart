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
        _StackedAvatars(task: task, mutedColor: mutedColor),
      ],
    );
  }
}

class _StackedAvatars extends StatelessWidget {
  const _StackedAvatars({required this.task, required this.mutedColor});

  final TaskItem task;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final hasAssignee = task.assignedToName != null;
    final hasCreator = task.createdByEmployeeName != null;

    if (!hasAssignee && !hasCreator) return const SizedBox.shrink();

    if (hasAssignee && hasCreator) {
      return SizedBox(
        width: 30,
        height: 22,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Creator — behind (right)
            Positioned(
              right: 0,
              child: UserAvatarWidget(
                name: task.createdByEmployeeName!,
                imageUrl: task.createdByProfileImageUrl,
                radius: 10,
                color: mutedColor,
                showBorder: true,
              ),
            ),
            // Assignee — front (left)
            Positioned(
              left: 0,
              child: UserAvatarWidget(
                name: task.assignedToName!,
                imageUrl: task.assignedToProfileImageUrl,
                radius: 10,
                showBorder: true,
              ),
            ),
          ],
        ),
      );
    }

    if (hasAssignee) {
      return UserAvatarWidget(
        name: task.assignedToName!,
        imageUrl: task.assignedToProfileImageUrl,
        radius: 10,
        showBorder: true,
      );
    }

    return UserAvatarWidget(
      name: task.createdByEmployeeName!,
      imageUrl: task.createdByProfileImageUrl,
      radius: 10,
      color: mutedColor,
      showBorder: true,
    );
  }
}
