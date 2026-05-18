import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/employee_task_comment_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/employee_task_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/employee_task_member_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/employee_task_progress_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/task_comments_tab.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/task_members_section.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/task_progress_section.dart';

class TabSectionWidget extends StatelessWidget {
  const TabSectionWidget({
    super.key,
    required this.readOnly,
    required this.task,
    required this.ctrl,
    required this.memberCtrl,
    required this.commentCtrl,
    required this.progressCtrl,
    required this.isDark,
    required List<(IconData, String)> tabs,
    required this.textColor,
    required this.mutedColor,
  }) : _tabs = tabs;

  final bool readOnly;
  final TaskItem task;
  final EmployeeTaskController ctrl;
  final EmployeeTaskMemberController memberCtrl;
  final TaskCommentController commentCtrl;
  final TaskProgressController progressCtrl;
  final bool isDark;
  final List<(IconData, String)> _tabs;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final canManageMembers =
        !readOnly && task.assignedToId == ctrl.currentEmployeeId;

    return Obx(() {
      final selectedTab = ctrl.selectedTab.value;
      final counts = [
        memberCtrl.currentTaskMembers.length,
        commentCtrl.currentTaskComments.length,
        progressCtrl.currentTaskProgresses.length,
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tab bar ───────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: isDark ? kCardDark : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final (icon, label) = _tabs[i];
                final active = selectedTab == i;
                final muted = isDark ? Colors.white38 : kTextMuted;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => ctrl.selectedTab.value = i,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: active ? kPrimary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: kPrimary.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            size: 13,
                            color: active ? Colors.white : muted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            label,
                            style: AppTextStyles.subTitle(
                              color: active ? Colors.white : muted,
                            ),
                          ),
                          if (counts[i] > 0) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? Colors.white.withValues(alpha: 0.30)
                                    : kPrimary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${counts[i]}',
                                style: AppTextStyles.subTitle(
                                  color: active
                                      ? Colors.white
                                      : kPrimary.withValues(alpha: 0.80),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 12),

          // ── Tab content ───────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: isDark ? kCardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: switch (selectedTab) {
                  0 =>
                    task.dueDate != null &&
                            task.dueDate!.isBefore(DateTime.now())
                        ? Center(
                            child: Text(
                              'task_expired'.tr,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white54
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          )
                        : TaskMembersSection(
                            ctrl: memberCtrl,
                            isDark: isDark,
                            textColor: textColor,
                            mutedColor: mutedColor,
                            canEdit: canManageMembers,
                            onAdd: (members) => memberCtrl.handleAddMember(
                              task.id,
                              members,
                              isDark,
                            ),
                            onRemove: (member) => memberCtrl.handleRemoveMember(
                              task.id,
                              member,
                              isDark,
                            ),
                            task: task,
                          ),
                  1 => TaskCommentsTab(
                    ctrl: commentCtrl,
                    isDark: isDark,
                    taskId: task.id,
                    canComment:
                        task.assignedToId == ctrl.currentEmployeeId &&
                        !readOnly,
                    task: task,
                  ),
                  _ =>
                    task.dueDate != null &&
                            task.dueDate!.isBefore(DateTime.now())
                        ? Center(
                            child: Text(
                              'This task cannot be edited (due date has passed)',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white54
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          )
                        : TaskProgressSection(
                            ctrl: progressCtrl,
                            taskId: task.id,
                            isDark: isDark,
                            textColor: textColor,
                            mutedColor: mutedColor,
                            canEdit: canManageMembers,
                            task: task,
                          ),
                },
              ),
            ),
          ),
        ],
      );
    });
  }
}
