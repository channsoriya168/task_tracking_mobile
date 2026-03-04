import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/data/models/user_model.dart';
import 'package:task_tracking_mobile/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/presentation/controllers/navigation_controller.dart';
import 'package:task_tracking_mobile/presentation/pages/admin/admin_home_page.dart';
import 'package:task_tracking_mobile/presentation/pages/admin/admin_staff_page.dart';
import 'package:task_tracking_mobile/presentation/pages/admin/admin_task_page.dart';
import 'package:task_tracking_mobile/presentation/pages/boss/boss_dashboard_page.dart';
import 'package:task_tracking_mobile/presentation/pages/boss/boss_staff_page.dart';
import 'package:task_tracking_mobile/presentation/pages/home_page.dart';
import 'package:task_tracking_mobile/presentation/pages/profile_page.dart';
import 'package:task_tracking_mobile/presentation/pages/tasks/task_page.dart';
import 'package:task_tracking_mobile/presentation/widgets/responsive_scaffold.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  List<NavItem> _navItemsForRole(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return const [
          NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            page: AdminHomePage(),
          ),
          NavItem(
            icon: Icons.list_alt_rounded,
            label: 'Tasks',
            page: AdminTaskPage(),
          ),
          NavItem(
            icon: Icons.people_rounded,
            label: 'Staff',
            page: AdminStaffPage(),
          ),
          NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            page: ProfilePage(),
          ),
        ];
      case UserRole.boss:
        return const [
          NavItem(
            icon: Icons.analytics_rounded,
            label: 'Dashboard',
            page: BossDashboardPage(),
          ),
          NavItem(
            icon: Icons.people_rounded,
            label: 'Staff',
            page: BossStaffPage(),
          ),
          NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            page: ProfilePage(),
          ),
        ];
      case UserRole.staff:
        return const [
          NavItem(
            icon: Icons.inbox_rounded,
            label: 'Available',
            page: HomePage(),
          ),
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
