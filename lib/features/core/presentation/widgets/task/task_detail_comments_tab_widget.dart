import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/helper/format_date.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_comment.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/task_detail_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_detail_avatar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_detail_empty_state_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_detail_tab_loader_widget.dart';

class TaskDetailCommentsTab extends StatelessWidget {
  const TaskDetailCommentsTab({
    super.key,
    required this.comments,
    required this.loading,
    required this.isDark,
    required this.ctrl,
    required this.canComment,
  });

  final List<TaskComment> comments;
  final bool loading;
  final bool isDark;
  final TaskDetailController ctrl;
  final bool canComment;

  @override
  Widget build(BuildContext context) {
    if (loading) return const TaskDetailTabLoader();

    final textColor = isDark ? Colors.white : kTextDark;
    final mutedColor = isDark ? Colors.white38 : kTextMuted;
    final bubbleBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.03);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Comment list ──────────────────────────────────────────────
        if (comments.isEmpty && !canComment)
          TaskDetailEmptyState(
            icon: Icons.chat_bubble_outline_rounded,
            message: 'No comments yet',
            isDark: isDark,
          )
        else if (comments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: TaskDetailEmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              message: 'No comments yet — be the first!',
              isDark: isDark,
            ),
          )
        else
          Padding(
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
                                    style: TextStyle(
                                        fontSize: 10, color: mutedColor),
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
          ),

        // ── Comment input (managers/admins only) ──────────────────────
        if (canComment) _CommentInput(ctrl: ctrl, isDark: isDark),
      ],
    );
  }
}

// ── Input field + send button ────────────────────────────────────────────────
class _CommentInput extends StatelessWidget {
  const _CommentInput({required this.ctrl, required this.isDark});

  final TaskDetailController ctrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.07);
    final inputBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04);
    final hintColor = isDark ? Colors.white38 : kTextMuted;
    final textColor = isDark ? Colors.white : kTextDark;

    return Column(
      children: [
        Divider(height: 1, thickness: 1, color: dividerColor),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Row(
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
                      hintStyle: TextStyle(fontSize: 13, color: hintColor),
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
                        onTap: ctrl.submitComment,
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
        ),
      ],
    );
  }
}
