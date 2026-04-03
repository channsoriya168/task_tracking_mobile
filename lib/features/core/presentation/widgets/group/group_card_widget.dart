// ── Position Card ─────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/action_button.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/group_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/confirm_delete_dialog.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/group/group_dialog.dart';

class GroupCardWidget extends StatelessWidget {
  const GroupCardWidget({
    required this.isDark,
    required this.ctrl,
    required this.group,
    required this.employeeCount,
  });

  final bool isDark;
  final GroupController ctrl;
  final Group group;
  final int employeeCount;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(group.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: kHighPriority.withAlpha(200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 22),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => ctrl.deleteGroup(group.id),
      child: GestureDetector(
        onTap: () => showGroupDialog(context, ctrl, isDark, group),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? kCardDark : kBgLight,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (group.color ?? kPrimary).withAlpha(isDark ? 30 : 20),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                // Left accent bar
                Container(
                  width: 5,
                  height: 72,
                  color: group.color ?? kPrimary,
                ),
                const SizedBox(width: 14),
                // Icon avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: (group.color ?? kPrimary).withAlpha(
                      isDark ? 40 : 25,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.group_rounded,
                    color: group.color ?? kPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : kTextDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.people_alt_rounded,
                            size: 12,
                            color: isDark ? Colors.grey[500] : kTextMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$employeeCount ${employeeCount == 1 ? 'group_member'.tr : 'group_members'.tr}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[500] : kTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ActionButton(
                  icon: Icons.edit_rounded,
                  color: group.color ?? kPrimary,
                  onTap: () =>
                      showGroupDialog(context, ctrl, isDark, group),
                ),
                const SizedBox(width: 6),
                ActionButton(
                  icon: Icons.delete_rounded,
                  color: kHighPriority,
                  onTap: () async {
                    final confirmed = await _confirmDelete(context);
                    if (confirmed == true) ctrl.deleteGroup(group.id);
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showConfirmDeleteDialog(
      context,
      title: 'group_dialog_delete_title'.tr,
      content: employeeCount > 0
          ? (employeeCount == 1
              ? 'group_confirm_delete_employee_msg'
                  .trParams({'count': '1', 'name': group.name})
              : 'group_confirm_delete_employees_msg'
                  .trParams({'count': '$employeeCount', 'name': group.name}))
          : 'group_confirm_delete_simple_msg'.trParams({'name': group.name}),
    );
  }
}
