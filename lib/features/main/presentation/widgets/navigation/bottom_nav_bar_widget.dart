import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/main/presentation/widgets/navigation/nav_item_widget.dart';
import 'package:task_tracking_mobile/features/employee/data/models/nav_item.dart';
import 'package:task_tracking_mobile/features/main/presentation/controllers/navigation_controller.dart';

class BottomNavBarWidget extends StatelessWidget {
  const BottomNavBarWidget({super.key, required this.items});

  final List<NavItem> items;

  @override
  Widget build(BuildContext context) {
    final NavigationController navController = Get.find();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final selected = navController.selectedIndex.value;
      return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              child: Row(
                children: List.generate(items.length, (i) {
                  return Expanded(
                    child: NavItemWidget(
                      item: items[i],
                      isSelected: selected == i,
                      isDark: isDark,
                      onTap: () => navController.changePage(i),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      );
    });
  }
}
