import 'dart:ui';
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
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: (isDarkMode ? kBgDark : kBgLight),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (isDarkMode ? Colors.white : Colors.black).withAlpha(
                    26,
                  ),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    color: Colors.black.withAlpha(isDarkMode ? 77 : 21),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 6,
                  ),
                  child: GNav(
                    rippleColor: kPrimary.withAlpha(26),
                    hoverColor: kPrimary.withAlpha(13),
                    gap: 8,
                    activeColor: Colors.white,
                    iconSize: 22,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    duration: const Duration(milliseconds: 300),
                    tabBackgroundColor: kPrimary,
                    tabBorderRadius: 50,
                    curve: Curves.easeInOutCubic,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
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
          ),
        ),
      ),
    );
  }
}
