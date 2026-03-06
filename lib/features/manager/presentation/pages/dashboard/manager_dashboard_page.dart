import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/responsive.dart';
import 'manager_dashboard_mobile_page.dart';
import 'manager_dashboard_tablet_page.dart';

class ManagerDashboardPage extends StatelessWidget {
  const ManagerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return const ManagerDashboardMobilePage();
    }
    // Tablet and desktop share the same layout
    return const ManagerDashboardTabletPage();
  }
}
