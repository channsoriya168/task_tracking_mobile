import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/app/utils/responsive.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/navigation/bottom_nav_bar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/navigation/navigation_rail_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';

class NavItem {
  final IconData icon;
  final String label;
  final Widget page;

  const NavItem({required this.icon, required this.label, required this.page});
}

class ResponsiveScaffold extends StatelessWidget {
  final List<NavItem> navItems;

  ResponsiveScaffold({super.key, required this.navItems});

  final NavigationController _navCtrl = Get.find();

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final bottomTabs = navItems
        .map((item) => GButton(icon: item.icon, text: item.label))
        .toList();

    final railItems = navItems
        .map((item) => NavRailItem(icon: item.icon, label: item.label))
        .toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      // Clamp index in case navItems count changed between roles
      final index = _navCtrl.selectedIndex.value.clamp(0, navItems.length - 1);
      return Scaffold(
        backgroundColor: isDark ? kBgDark : kBgLight,
        body: SafeArea(
          bottom: false,
          child: Row(
            children: [
              if (!isMobile) NavigationRailWidget(items: railItems),
              Expanded(child: navItems[index].page),
            ],
          ),
        ),
        bottomNavigationBar: isMobile
            ? BottomNavBarWidget(tabs: bottomTabs)
            : null,
      );
    });
  }
}
