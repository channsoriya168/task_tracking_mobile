import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/presentation/controllers/navigation_controller.dart';
import 'package:task_tracking_mobile/presentation/widgets/navigation/bottom_nav_bar_widget.dart';
import 'package:task_tracking_mobile/presentation/widgets/navigation/navigation_rail_widget.dart';

class ResponsiveScaffold extends StatelessWidget {
  final NavigationController navController = Get.find();
  final List<Widget> pages;

  ResponsiveScaffold({required this.pages});
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800;
    return Obx(
      () => Scaffold(
        body: Row(
          children: [
            if (!isMobile) NavigationRailWidget(),
            Expanded(child: pages[navController.selectedIndex.value]),
          ],
        ),
        bottomNavigationBar: isMobile ? BottomNavBarWidget() : null,
      ),
    );
  }
}
