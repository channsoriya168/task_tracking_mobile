import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/presentation/controllers/navigation_controller.dart';

class BottomNavBarWidget extends StatelessWidget {
  const BottomNavBarWidget({super.key, required this.tabs});

  final List<GButton> tabs;

  @override
  Widget build(BuildContext context) {
    final NavigationController navController = Get.find();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(
      () => Container(
        margin: kNavMargin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? kBgDark : kBgLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withAlpha(26),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    color: Colors.black.withAlpha(isDark ? 77 : 21),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: kNavContainer,
                  child: GNav(
                    rippleColor: kPrimary.withAlpha(26),
                    hoverColor: kPrimary.withAlpha(13),
                    gap: 8,
                    activeColor: Colors.white,
                    iconSize: 22,
                    padding: kNavPadding,
                    duration: const Duration(milliseconds: 300),
                    tabBackgroundColor: kPrimary,
                    tabBorderRadius: 50,
                    curve: Curves.easeInOutCubic,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    tabs: tabs,
                    selectedIndex: navController.selectedIndex.value,
                    onTabChange: (i) {
                      // Clamp to valid range in case tabs count changed
                      if (i < tabs.length) navController.changePage(i);
                    },
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
