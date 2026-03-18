import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/helper/format_date.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_comment.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_detail_avatar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_detail_empty_state_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_detail_tab_loader_widget.dart';

class TaskDetailCommentsTab extends StatelessWidget {
  const TaskDetailCommentsTab({
    super.key,
    required this.comments,
    required this.loading,
    required this.isDark,
  });

  final List<TaskComment> comments;
  final bool loading;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (loading) return const TaskDetailTabLoader();
    if (comments.isEmpty) {
      return TaskDetailEmptyState(
        icon: Icons.chat_bubble_outline_rounded,
        message: 'No comments yet',
        isDark: isDark,
      );
    }

    final textColor = isDark ? Colors.white : kTextDark;
    final mutedColor = isDark ? Colors.white38 : kTextMuted;
    final bubbleBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.03);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          for (int i = 0; i < comments.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TaskDetailAvatar(
                  name: comments[i].employeeName,
                  imageUrl: comments[i].employeeProfileImageUrl,
                  size: 30,
                  color: kPrimary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comments[i].employeeName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          if (comments[i].createdAt != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              formatDate(comments[i].createdAt!),
                              style: TextStyle(fontSize: 10, color: mutedColor),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: bubbleBg,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Text(
                          comments[i].content,
                          style: TextStyle(
                            fontSize: 13,
                            color: textColor,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
