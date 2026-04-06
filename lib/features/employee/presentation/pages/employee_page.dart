import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/responsive.dart';
import 'package:task_tracking_mobile/features/employee/presentation/pages/employee_mobile_page.dart';
import 'package:task_tracking_mobile/features/employee/presentation/pages/employee_tablet_page.dart';

class EmployeePage extends StatelessWidget {
  const EmployeePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return const EmployeeMobilePage();
    }
    return const EmployeeTabletPage();
  }
}
