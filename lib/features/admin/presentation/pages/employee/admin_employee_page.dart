import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/responsive.dart';
import 'package:task_tracking_mobile/features/admin/presentation/pages/employee/admin_employee_mobile_page.dart';
import 'package:task_tracking_mobile/features/admin/presentation/pages/employee/admin_employee_tablet_page.dart';

class AdminEmployeePage extends StatelessWidget {
  const AdminEmployeePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return const AdminEmployeeMobilePage();
    }
    return const AdminEmployeeTabletPage();
  }
}
