import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/presentation/controllers/navigation_controller.dart';

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
        width: 72,
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
            children: [
              const SizedBox(height: 20),
              // Logo
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.task_alt_rounded, color: kPrimary, size: 22),
              ),
              const SizedBox(height: 28),
              // Nav items
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final selected = navController.selectedIndex.value == index;
                return _RailItem(
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

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? kPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected
                  ? Colors.white
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
