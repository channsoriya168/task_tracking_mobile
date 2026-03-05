import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/employee/manager_employee_page.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/manager_profile_page.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/home/manager_dashboard_page.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/task/manager_task_page.dart';
import 'package:task_tracking_mobile/features/staff/data/models/user_model.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/responsive_scaffold.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';
import 'package:task_tracking_mobile/features/staff/presentation/pages/home_page.dart';
import 'package:task_tracking_mobile/features/staff/presentation/pages/profile_page.dart';
import 'package:task_tracking_mobile/features/staff/presentation/pages/tasks/task_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  List<NavItem> _navItemsForRole(UserRole? role) {
    switch (role) {
      case UserRole.manager:
        return const [
          NavItem(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            page: ManagerDashboardPage(),
          ),
          NavItem(
            icon: Icons.list_alt_rounded,
            label: 'Tasks',
            page: ManagerTaskPage(),
          ),
          NavItem(
            icon: Icons.people_rounded,
            label: 'Employees',
            page: ManagerEmployeePage(),
          ),
          NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            page: ManagerProfilePage(),
          ),
        ];
      case UserRole.admin:
        return const [
          NavItem(
            icon: Icons.analytics_rounded,
            label: 'Dashboard',
            page: HomePage(),
          ),
          NavItem(
            icon: Icons.people_rounded,
            label: 'Staff',
            page: ProfilePage(),
          ),
          NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            page: ProfilePage(),
          ),
        ];
      case UserRole.staff:
        return const [
          NavItem(icon: Icons.home, label: 'Home', page: HomePage()),
          NavItem(
            icon: Icons.task_rounded,
            label: 'My Tasks',
            page: TasksPage(),
          ),
          NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            page: ProfilePage(),
          ),
        ];
      default:
        return const [
          NavItem(icon: Icons.home_rounded, label: 'Home', page: ProfilePage()),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Obx(() {
      final role = auth.currentUser.value?.role;
      final navItems = _navItemsForRole(role);

      // Reset nav index when role changes to avoid out-of-bounds
      final navCtrl = Get.find<NavigationController>();
      if (navCtrl.selectedIndex.value >= navItems.length) {
        navCtrl.changePage(0);
      }

      return ResponsiveScaffold(navItems: navItems);
    });
  }
}
