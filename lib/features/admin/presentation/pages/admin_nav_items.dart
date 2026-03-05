import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/features/core/data/models/nav_item.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/responsive_scaffold.dart';
import 'package:task_tracking_mobile/features/admin/presentation/pages/home/admin_dashboard_page.dart';
import 'package:task_tracking_mobile/features/admin/presentation/pages/task/admin_task_page.dart';
import 'package:task_tracking_mobile/features/admin/presentation/pages/employee/admin_employee_page.dart';
import 'package:task_tracking_mobile/features/admin/presentation/pages/admin_profile_page.dart';

const adminNavItems = <NavItem>[
  NavItem(
    icon: Icons.analytics_rounded,
    label: 'Dashboard',
    page: AdminDashboardPage(),
  ),
  NavItem(
    icon: Icons.list_alt_rounded,
    label: 'Tasks',
    page: AdminTaskPage(),
  ),
  NavItem(
    icon: Icons.people_rounded,
    label: 'Employee',
    page: AdminEmployeePage(),
  ),
  NavItem(
    icon: Icons.person_rounded,
    label: 'Profile',
    page: AdminProfilePage(),
  ),
];
