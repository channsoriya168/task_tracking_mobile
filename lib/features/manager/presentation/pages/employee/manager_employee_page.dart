import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/responsive.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/employee/manager_employee_mobile_page.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/employee/manager_employee_tablet_page.dart';

class ManagerEmployeePage extends StatelessWidget {
  const ManagerEmployeePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return const ManagerEmployeeMobilePage();
    }
    return const ManagerEmployeeTabletPage();
  }
}
