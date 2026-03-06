import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';
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

  bool get hasQr => employee?.hasQr ?? false;
  bool get isQrExpired => employee?.isQrExpired ?? false;

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
    if (!hasQr || isQrExpired)
      EmployeeMenuItem(
        action: EmployeeMenuAction.generateQr,
        icon: Icons.qr_code_rounded,
        label: isQrExpired ? 'Regenerate QR Code' : 'Generate QR Code',
        isPrimary: true,
      ),
    if (hasQr && !isQrExpired)
      const EmployeeMenuItem(
        action: EmployeeMenuAction.resetQr,
        icon: Icons.refresh_rounded,
        label: 'Reset QR Code',
        isWarning: true,
      ),
    const EmployeeMenuItem(
      action: EmployeeMenuAction.delete,
      icon: Icons.delete_rounded,
      label: 'Delete Employee',
      isDanger: true,
    ),
  ];

  // ── Actions (pure business logic — no widgets) ─────────────────

  void openDetail() {
    Get.back();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Get.to(() => EmployeeDetailPage(employeeId: employeeId)),
    );
  }

  void edit() {
    final emp = employee;
    if (emp == null) return;
    Get.back();
    _empCtrl.showDialog(isDark, emp);
  }

  void generateQr() {
    _empCtrl.generateQrCode(employeeId);
    Get.back();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Get.to(() => EmployeeDetailPage(employeeId: employeeId)),
    );
  }

  void resetQr() {
    _empCtrl.resetQrCode(employeeId);
    Get.back();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Get.to(() => EmployeeDetailPage(employeeId: employeeId)),
    );
  }

  void deleteEmployee() {
    _empCtrl.deleteEmployee(employeeId);
    Get.back();
  }
}