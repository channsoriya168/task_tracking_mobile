import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/rail_item_widget.dart';

class NavRailItem {
  final IconData icon;
  final String label;

  const NavRailItem({required this.icon, required this.label});
}

class NavigationRailWidget extends StatelessWidget {
  const NavigationRailWidget({super.key, required this.items});

  final List<NavRailItem> items;

  @override
  Widget build(BuildContext context) {
    final NavigationController navController = Get.find();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(
      () => Container(
        width: 150,
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 60 : 12),
              blurRadius: 12,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Logo
              Container(
                width: 150,
                // height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    width: 150,
                    // height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Nav items
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final selected = navController.selectedIndex.value == index;
                return RailItem(
                  icon: item.icon,
                  label: item.label,
                  selected: selected,
                  isDark: isDark,
                  onTap: () => navController.changePage(index),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
