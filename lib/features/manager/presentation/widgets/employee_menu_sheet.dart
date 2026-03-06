import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee_menu_item.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_menu_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_menu_widgets.dart';

// ── Entry point ────────────────────────────────────────────────
void showEmployeeMenuSheet(
  BuildContext context, {
  required Employee employee,
  required EmployeeController ctrl,
  required bool isDark,
  required Color accentColor,
}) {
  final menuCtrl = Get.put(
    EmployeeMenuController(employeeId: employee.id, isDark: isDark),
    tag: employee.id,
  );

  Get.bottomSheet(
    _EmployeeMenuSheet(
      menuCtrl: menuCtrl,
      isDark: isDark,
      accentColor: accentColor,
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  ).then((_) => Get.delete<EmployeeMenuController>(tag: employee.id));
}

// ── Confirmation dialogs (view layer — no business logic) ──────
Future<bool> _confirmResetQr() async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      title: const Text('Reset QR Code'),
      content: const Text(
        'This will invalidate the current QR code and generate a new one. '
        'The employee must use the new QR code to log in.',
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          style: TextButton.styleFrom(foregroundColor: kHighPriority),
          child: const Text('Reset'),
        ),
      ],
    ),
  );
  return result == true;
}

Future<bool> _confirmDelete(String name) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      title: const Text('Delete Employee'),
      content: Text('Remove "$name" from the team?'),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          style: TextButton.styleFrom(foregroundColor: kHighPriority),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return result == true;
}

// ── Sheet ──────────────────────────────────────────────────────
class _EmployeeMenuSheet extends StatelessWidget {
  const _EmployeeMenuSheet({
    required this.menuCtrl,
    required this.isDark,
    required this.accentColor,
  });

  final EmployeeMenuController menuCtrl;
  final bool isDark;
  final Color accentColor;

  Future<void> _handleAction(EmployeeMenuAction action) async {
    switch (action) {
      case EmployeeMenuAction.viewDetail:
        menuCtrl.openDetail();
      case EmployeeMenuAction.edit:
        menuCtrl.edit();
      case EmployeeMenuAction.generateQr:
        menuCtrl.generateQr();
      case EmployeeMenuAction.resetQr:
        if (await _confirmResetQr()) menuCtrl.resetQr();
      case EmployeeMenuAction.delete:
        final name = menuCtrl.employee?.name ?? '';
        if (await _confirmDelete(name)) menuCtrl.deleteEmployee();
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

      return Container(
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmployeeMenuHandle(isDark: isDark),
            const SizedBox(height: 16),
            EmployeeMenuSummary(
              emp: emp,
              accentColor: accentColor,
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            Divider(
              color: isDark
                  ? Colors.white.withAlpha(12)
                  : Colors.black.withAlpha(8),
            ),
            const SizedBox(height: 4),
            ...menuCtrl.menuItems.map(
              (item) => EmployeeMenuItemTile(
                item: item,
                isDark: isDark,
                onTap: () => _handleAction(item.action),
              ),
            ),
          ],
        ),
      );
    });
  }
}