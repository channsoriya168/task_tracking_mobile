import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/presentation/controllers/navigation_controller.dart';

class BottomNavBarWidget extends StatelessWidget {
  const BottomNavBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navController = Get.find();
    final List<BottomNavigationBarItem> items = const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tasks'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];
    return Obx(
      () => BottomNavigationBar(
        currentIndex: navController.selectedIndex.value,
        onTap: navController.changePage,
        items: items,
      ),
    );
  }
}
