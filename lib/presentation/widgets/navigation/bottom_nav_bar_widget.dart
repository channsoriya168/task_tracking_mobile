import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/presentation/controllers/navigation_controller.dart';

class BottomNavBarWidget extends StatelessWidget {
  const BottomNavBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navController = Get.find();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? kTextDark : Colors.white,
          // boxShadow: [
          //   BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
          // ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: kPrimary.withOpacity(0.1),
              hoverColor: kPrimary.withOpacity(0.05),
              gap: 8,
              activeColor: Colors.white,
              iconSize: 22,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              duration: Duration(milliseconds: 300),
              tabBackgroundColor: kPrimary,
              tabBorderRadius: 50,
              curve: Curves.easeInOutCubic,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              tabs: [
                GButton(icon: Icons.home_rounded, text: 'Home'),
                GButton(icon: Icons.list_rounded, text: 'Tasks'),
                GButton(icon: Icons.person_rounded, text: 'Profile'),
              ],
              selectedIndex: navController.selectedIndex.value,
              onTabChange: navController.changePage,
            ),
          ),
        ),
      ),
    );
  }
}
