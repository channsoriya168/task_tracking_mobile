import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/dashboard/pages/dashboard_page.dart';
import 'package:task_tracking_mobile/features/employee/data/models/nav_item.dart';
import 'package:task_tracking_mobile/features/employee/presentation/pages/employee_page.dart';
import 'package:task_tracking_mobile/features/notification/presentation/pages/notification_page.dart';
import 'package:task_tracking_mobile/features/task/presentation/pages/admin_and_manager/task_page.dart';
import 'package:task_tracking_mobile/features/task/presentation/pages/employee_task_page.dart';
import 'package:task_tracking_mobile/core/constants/user_role.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/main/presentation/widgets/responsive_scaffold.dart';
import 'package:task_tracking_mobile/features/main/presentation/controllers/navigation_controller.dart';
import 'package:task_tracking_mobile/features/dashboard/pages/employee_home_page.dart';
import 'package:task_tracking_mobile/features/profile/presentation/pages/profile_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  List<NavItem> _navItemsForRole(UserRole? role) {
    switch (role) {
      case UserRole.manager:
        return [
          NavItem(
            icon: Icons.dashboard_rounded,
            label: 'nav_dashboard'.tr,
            page: const DashboardPage(),
          ),
          NavItem(
            icon: Icons.list_alt_rounded,
            label: 'nav_tasks'.tr,
            page: const TaskPage(),
          ),
          NavItem(
            icon: Icons.people_rounded,
            label: 'nav_employees'.tr,
            page: const EmployeePage(),
          ),
          NavItem(
            icon: Icons.notifications_rounded,
            label: 'nav_notifications'.tr,
            page: const NotificationPage(),
          ),
          NavItem(
            icon: Icons.person_rounded,
            label: 'nav_profile'.tr,
            page: const ProfilePage(),
          ),
        ];
      case UserRole.admin:
        return [
          NavItem(
            icon: Icons.analytics_rounded,
            label: 'nav_dashboard'.tr,
            page: const DashboardPage(),
          ),
          NavItem(
            icon: Icons.list_alt_rounded,
            label: 'nav_tasks'.tr,
            page: const TaskPage(),
          ),
          NavItem(
            icon: Icons.people_rounded,
            label: 'nav_employee'.tr,
            page: const EmployeePage(),
          ),
          NavItem(
            icon: Icons.notifications_rounded,
            label: 'nav_notifications'.tr,
            page: const NotificationPage(),
          ),
          NavItem(
            icon: Icons.person_rounded,
            label: 'nav_profile'.tr,
            page: const ProfilePage(),
          ),
        ];
      case UserRole.employee:
        return [
          NavItem(
            icon: Icons.home_rounded,
            label: 'nav_home'.tr,
            page: const EmployeeHomePage(),
          ),
          NavItem(
            icon: Icons.task_rounded,
            label: 'nav_my_tasks'.tr,
            page: const EmployeeTaskPage(),
          ),
          NavItem(
            icon: Icons.notifications_rounded,
            label: 'nav_notifications'.tr,
            page: const NotificationPage(),
          ),
          NavItem(
            icon: Icons.person_rounded,
            label: 'nav_profile'.tr,
            page: const ProfilePage(),
          ),
        ];
      default:
        return [
          NavItem(
            icon: Icons.home_rounded,
            label: 'nav_home'.tr,
            page: const ProfilePage(),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Obx(() {
      final role = auth.role;
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
