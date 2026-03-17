import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee_menu_item.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';

import 'package:task_tracking_mobile/features/manager/presentation/pages/employee/employee_detail_page.dart';

class EmployeeMenuController extends GetxController {
  EmployeeMenuController({required this.employeeId, required this.isDark});

  final String employeeId;
  final bool isDark;

  final _empCtrl = Get.find<EmployeeController>();

  // ── Reactive state ─────────────────────────────────────────────
  Employee? get employee =>
      _empCtrl.employees.firstWhereOrNull((e) => e.id == employeeId);

  // ── Menu items ─────────────────────────────────────────────────
  List<EmployeeMenuItem> get menuItems => [
    const EmployeeMenuItem(
      action: EmployeeMenuAction.viewDetail,
      icon: Icons.person_rounded,
      label: 'View Detail',
    ),
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
      action: EmployeeMenuAction.delete,
      icon: Icons.delete_rounded,
      label: 'Delete Employee',
      isDanger: true,
    ),
  ];

  // ── Actions ────────────────────────────────────────────────────

  void openDetail() {
    Get.back();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Get.to(
        () => EmployeeDetailPage(employeeId: employeeId, viewOnly: true),
      ),
    );
  }

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
