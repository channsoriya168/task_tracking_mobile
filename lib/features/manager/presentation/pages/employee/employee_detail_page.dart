import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/responsive.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/employee/employee_detail_mobile_page.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/employee/employee_detail_tablet_page.dart';

class EmployeeDetailPage extends StatelessWidget {
  const EmployeeDetailPage({super.key, required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EmployeeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final emp = ctrl.employees.firstWhereOrNull((e) => e.id == employeeId);

      // Employee was deleted — go back
      if (emp == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
        return const SizedBox.shrink();
      }

      if (Responsive.isMobile(context)) {
        return EmployeeDetailMobilePage(emp: emp, ctrl: ctrl, isDark: isDark);
      }
      return EmployeeDetailTabletPage(emp: emp, ctrl: ctrl, isDark: isDark);
    });
  }
}