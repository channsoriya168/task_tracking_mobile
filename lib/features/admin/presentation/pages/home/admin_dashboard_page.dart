import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/responsive.dart';
import 'admin_dashboard_mobile_page.dart';
import 'admin_dashboard_tablet_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return const AdminDashboardMobilePage();
    }
    // Tablet and desktop share the same layout
    return const AdminDashboardTabletPage();
  }
}
