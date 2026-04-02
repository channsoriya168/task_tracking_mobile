import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/format_date.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_comment.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/user_avatar_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/task_comment_controller.dart';

class TaskCommentsTab extends StatelessWidget {
  const TaskCommentsTab({
    super.key,
    required this.ctrl,
    required this.isDark,
    required this.taskId,
    required this.canComment,
  });

  final TaskCommentController ctrl;
  final bool isDark;
  final String taskId;
  final bool canComment;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : kTextDark;
    final mutedColor = isDark ? Colors.white38 : kTextMuted;
    final bubbleBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.03);

    return Obx(() {
      final comments = ctrl.currentTaskComments.toList();
      final loading = ctrl.commentsLoading.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (comments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 32,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    canComment
                        ? 'No comments yet — be the first!'
                        : 'No comments yet.',
                    style: TextStyle(fontSize: 13, color: mutedColor),
                  ),
                ],
              ),
            )
          else
            _CommentList(
              comments: comments,
              isDark: isDark,
              textColor: textColor,
              mutedColor: mutedColor,
              bubbleBg: bubbleBg,
            ),
          if (canComment)
            _CommentInput(
              ctrl: ctrl,
              taskId: taskId,
              isDark: isDark,
              mutedColor: mutedColor,
              textColor: textColor,
            ),
        ],
      );
    });
  }
}

// ── Comment list ──────────────────────────────────────────────────────────────

class _CommentList extends StatelessWidget {
  const _CommentList({
    required this.comments,
    required this.isDark,
    required this.textColor,
    required this.mutedColor,
    required this.bubbleBg,
  });

  final List<TaskComment> comments;
  final bool isDark;
  final Color textColor;
  final Color mutedColor;
  final Color bubbleBg;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < comments.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatarWidget(
                name: comments[i].employeeName,
                imageUrl: comments[i].employeeProfileImageUrl,
                radius: 15,
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
    );
  }
}

// ── Comment input ─────────────────────────────────────────────────────────────

class _CommentInput extends StatelessWidget {
  const _CommentInput({
    required this.ctrl,
    required this.taskId,
    required this.isDark,
    required this.mutedColor,
    required this.textColor,
  });

  final TaskCommentController ctrl;
  final String taskId;
  final bool isDark;
  final Color mutedColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.07);
    final inputBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04);

    return Column(
      children: [
        const SizedBox(height: 12),
        Divider(height: 1, thickness: 1, color: dividerColor),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: dividerColor),
                ),
                child: TextField(
                  controller: ctrl.commentTextController,
                  minLines: 1,
                  maxLines: 4,
                  style: TextStyle(fontSize: 13, color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Write a comment…',
                    hintStyle: TextStyle(fontSize: 13, color: mutedColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                  textInputAction: TextInputAction.newline,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => ctrl.isSendingComment.value
                  ? const SizedBox(
                      width: 36,
                      height: 36,
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kPrimary,
                          ),
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: () => ctrl.submitComment(taskId),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: kPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
