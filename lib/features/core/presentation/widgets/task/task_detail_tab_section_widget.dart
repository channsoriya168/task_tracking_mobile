import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/enums/user_role.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/task_detail_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_detail_comments_tab_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_detail_members_tab_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_detail_progress_tab_widget.dart';

class TaskDetailTabSection extends StatelessWidget {
  const TaskDetailTabSection({
    super.key,
    required this.ctrl,
    required this.isDark,
  });

  final TaskDetailController ctrl;
  final bool isDark;

  static const _tabs = [
    (Icons.group_outlined, 'Members'),
    (Icons.chat_bubble_outline_rounded, 'Comments'),
    (Icons.trending_up_rounded, 'Progress'),
  ];

  static bool _computeCanComment() {
    try {
      final role = Get.find<AuthController>().role;
      return role == UserRole.admin || role == UserRole.manager;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canComment = _computeCanComment();
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.07);

    return Obx(() {
      final selected = ctrl.selectedTab.value;
      final counts = [
        ctrl.members.length,
        ctrl.comments.length,
        ctrl.progresses.length,
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Pill tab bar ────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final (icon, label) = _tabs[i];
                final active = selected == i;
                final mutedColor = isDark ? Colors.white38 : kTextMuted;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => ctrl.selectTab(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? kPrimary : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            size: 13,
                            color: active ? Colors.white : mutedColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$label (${counts[i]})',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  active ? FontWeight.w600 : FontWeight.w500,
                              color: active ? Colors.white : mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 12),

          // ── Tab content ──────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: switch (selected) {
                0 => TaskDetailMembersTab(
                    members: ctrl.members,
                    loading: ctrl.membersLoading.value,
                    isDark: isDark,
                  ),
                1 => TaskDetailCommentsTab(
                    comments: ctrl.comments,
                    loading: ctrl.commentsLoading.value,
                    isDark: isDark,
                    ctrl: ctrl,
                    canComment: canComment,
                  ),
                _ => TaskDetailProgressTab(
                    progresses: ctrl.progresses,
                    loading: ctrl.progressesLoading.value,
                    isDark: isDark,
                  ),
              },
            ),
          ),
        ],
      );
    });
  }
}
