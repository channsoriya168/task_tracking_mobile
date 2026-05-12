import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/enums/user_role.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/employee/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/employee/data/models/employee_menu_item.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_controller.dart';

class EmployeeMenuController extends GetxController {
  EmployeeMenuController({required this.employeeId, required this.isDark});

  final String employeeId;
  final bool isDark;

  final _empCtrl = Get.find<EmployeeController>();

  // ── Reactive state ─────────────────────────────────────────────
  Employee? get employee =>
      _empCtrl.employees.firstWhereOrNull((e) => e.id == employeeId);

  /// Returns true when the current Manager is trying to act on a Manager/Admin.
  /// Admins can always manage everyone.
  bool get isProtectedFromCurrentUser {
    final authRole = Get.find<AuthController>().role;
    if (authRole != UserRole.manager) return false;
    final targetRole = employee?.role?.toLowerCase() ?? '';
    return targetRole == 'manager' || targetRole == 'admin';
  }

  // ── Menu items ─────────────────────────────────────────────────
  List<EmployeeMenuItem> get menuItems {
    if (isProtectedFromCurrentUser) return [];
    return [
      const EmployeeMenuItem(
        action: EmployeeMenuAction.edit,
        icon: Icons.edit_rounded,
        label: 'Edit Employee',
      ),
      const EmployeeMenuItem(
        action: EmployeeMenuAction.changePassword,
        icon: Icons.lock_reset_rounded,
        label: 'Change Password',
        isWarning: true,
      ),
      const EmployeeMenuItem(
        action: EmployeeMenuAction.generateQr,
        icon: Icons.qr_code_rounded,
        label: 'Generate QR Login',
        isPrimary: true,
      ),
      const EmployeeMenuItem(
        action: EmployeeMenuAction.delete,
        icon: Icons.delete_rounded,
        label: 'Delete Employee',
        isDanger: true,
      ),
    ];
  }

  // ── Actions ────────────────────────────────────────────────────

  void edit() {
    final emp = employee;
    if (emp == null) return;
    Get.back();
    Get.find<EmployeeController>().showEditDialog(emp);
  }

  void deleteEmployee() {
    _empCtrl.deleteEmployee(employeeId);
    Get.back();
  }
}
