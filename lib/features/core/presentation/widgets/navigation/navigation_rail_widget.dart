import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
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

    final double railWidth = (MediaQuery.of(context).size.width * 0.20).clamp(
      160.0,
      220.0,
    );

    return Obx(
      () => Container(
        width: railWidth,
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Logo scrolls with nav items
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
