import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/widgets/user_avatar_widget.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';

class StackedAvatarsWidget extends StatelessWidget {
  const StackedAvatarsWidget({
    super.key,
    required this.task,
    required this.mutedColor,
  });

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
