import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_employee_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_employee_form_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/admin_employee_widgets.dart';

class AdminEmployeeMobilePage extends StatelessWidget {
  const AdminEmployeeMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminEmployeeController>();
    final AdminEmployeeFormController formCtrl = Get.find();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: Column(
        children: [
          AdminEmployeeHeader(isDark: isDark, ctrl: ctrl),
          AdminEmployeeGroupDropdown(isDark: isDark, ctrl: ctrl),
          AdminEmployeeSearchBar(isDark: isDark, ctrl: ctrl),
          Expanded(
            child: AdminEmployeeList(isDark: isDark, ctrl: ctrl),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        onPressed: () => formCtrl.showCreateDialog(isDark),
        child: const Icon(Icons.person_add_rounded),
      ),
    );
  }
}
