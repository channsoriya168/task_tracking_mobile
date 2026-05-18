// ── Position Card ─────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
import 'package:task_tracking_mobile/core/widgets/no_internet_dialog.dart';
import 'package:task_tracking_mobile/features/group/presentation/controllers/group_controller.dart';
import 'package:task_tracking_mobile/core/widgets/confirm_delete_dialog.dart';
import 'package:task_tracking_mobile/features/group/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/group/presentation/widgets/group_dialog.dart';

enum _GroupCardMenuAction { edit, delete }

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
    final menuBgColor = isDark ? kCardDark : Colors.white;
    final menuBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final menuShadowColor = isDark
        ? Colors.black.withValues(alpha: 0.35)
        : Colors.black.withValues(alpha: 0.12);
    final menuTextColor = isDark ? Colors.white : kTextDark;

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
      confirmDismiss: (_) async {
        if (!Get.find<NetworkController>().isConnected.value) {
          ctrl.isOfflineDialogOpen.value = true;
          await showNoInternetDialog(isDark: isDark, redirectCount: 1);
          ctrl.isOfflineDialogOpen.value = false;
          return false;
        }
        return _confirmDelete(context);
      },
      onDismissed: (_) => ctrl.deleteGroup(group.id),
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
          child: Column(
            children: [
              Row(
                children: [
                  // Left accent bar — stretches with content
                  Container(width: 5, color: group.color ?? kPrimary),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                          if (group.description != null &&
                              group.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              group.description!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[500] : kTextMuted,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  PopupMenuButton<_GroupCardMenuAction>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: isDark ? Colors.grey[300] : kTextMuted,
                    ),
                    color: menuBgColor,
                    surfaceTintColor: Colors.transparent,
                    elevation: 8,
                    shadowColor: menuShadowColor,
                    position: PopupMenuPosition.under,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: menuBorderColor),
                    ),
                    tooltip: 'actions'.tr,
                    onSelected: (action) async {
                      final offline =
                          !Get.find<NetworkController>().isConnected.value;
                      if (offline) {
                        ctrl.isOfflineDialogOpen.value = true;
                        await showNoInternetDialog(
                          isDark: isDark,
                          redirectCount: 1,
                        );
                        ctrl.isOfflineDialogOpen.value = false;
                        return;
                      }

                      if (action == _GroupCardMenuAction.edit) {
                        showGroupDialog(
                          context,
                          ctrl,
                          isDark,
                          group,
                          ctrl.isOfflineDialogOpen,
                        );
                        return;
                      }

                      final confirmed = await _confirmDelete(context);
                      if (confirmed == true) ctrl.deleteGroup(group.id);
                    },
                    itemBuilder: (menuContext) => [
                      PopupMenuItem<_GroupCardMenuAction>(
                        value: _GroupCardMenuAction.edit,
                        height: 42,
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              size: 14,
                              color: group.color ?? kPrimary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'edit'.tr,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: menuTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<_GroupCardMenuAction>(
                        value: _GroupCardMenuAction.delete,
                        height: 42,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_rounded,
                              size: 14,
                              color: kHighPriority,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'delete'.tr,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kHighPriority,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              Divider(
                // height: 16,
                thickness: 1,
                color: isDark ? Colors.grey[700] : Colors.grey[300],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
              ),
            ],
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
                ? 'group_confirm_delete_employee_msg'.trParams({
                    'count': '1',
                    'name': group.name,
                  })
                : 'group_confirm_delete_employees_msg'.trParams({
                    'count': '$employeeCount',
                    'name': group.name,
                  }))
          : 'group_confirm_delete_simple_msg'.trParams({'name': group.name}),
    );
  }
}
