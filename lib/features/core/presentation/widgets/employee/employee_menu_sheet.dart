import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/data/models/employee_menu_item.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_menu_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_menu_dialogs.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_menu_widgets.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_reset_password_sheet.dart';

void showEmployeeMenuSheet(
  BuildContext context, {
  required EmployeeController ctrl,
  required bool isDark,
  required Color accentColor,
  required String employeeId,
}) {
  final menuCtrl = Get.put(
    EmployeeMenuController(employeeId: employeeId, isDark: isDark),
    tag: employeeId,
  );

  Get.bottomSheet(
    _EmployeeMenuSheet(
      menuCtrl: menuCtrl,
      isDark: isDark,
      accentColor: accentColor,
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  ).then((_) => Get.delete<EmployeeMenuController>(tag: employeeId));
}

class _EmployeeMenuSheet extends StatelessWidget {
  const _EmployeeMenuSheet({
    required this.menuCtrl,
    required this.isDark,
    required this.accentColor,
  });

  final EmployeeMenuController menuCtrl;
  final bool isDark;
  final Color accentColor;

  Future<void> _handleAction(
    BuildContext context,
    EmployeeMenuAction action,
  ) async {
    switch (action) {
      case EmployeeMenuAction.viewDetail:
        menuCtrl.openDetail();
      case EmployeeMenuAction.edit:
        menuCtrl.edit();
      case EmployeeMenuAction.changePassword:
        final emp = menuCtrl.employee;
        if (emp == null) return;
        Get.back();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showResetPasswordSheet(
            context,
            employee: emp,
            ctrl: Get.find<EmployeeController>(),
            isDark: isDark,
          );
        });
      case EmployeeMenuAction.delete:
        final name = menuCtrl.employee?.fullName ?? '';
        if (await confirmDeleteEmployee(name)) menuCtrl.deleteEmployee();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final emp = menuCtrl.employee;

      if (emp == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
        return const SizedBox.shrink();
      }

      final dividerColor = isDark
          ? Colors.white.withAlpha(10)
          : Colors.black.withAlpha(8);

      return Container(
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Employee row
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: accentColor.withAlpha(40),
                  backgroundImage: emp.profileImageUrl != null
                      ? NetworkImage(emp.profileImageUrl!)
                      : null,
                  child: emp.profileImageUrl == null
                      ? Text(
                          emp.fullName.isNotEmpty
                              ? emp.fullName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        emp.fullName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : kTextDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        emp.email,
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
            const SizedBox(height: 16),

            Divider(height: 1, color: dividerColor),
            const SizedBox(height: 4),

            // Menu items
            ...menuCtrl.menuItems.map(
              (item) => EmployeeMenuItemTile(
                item: item,
                isDark: isDark,
                onTap: () => _handleAction(context, item.action),
              ),
            ),
          ],
        ),
      );
    });
  }
}
