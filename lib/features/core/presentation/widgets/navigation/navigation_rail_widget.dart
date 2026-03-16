import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/logo.jpg',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Nav items
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: items.asMap().entries.map((entry) {
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
                  }).toList(),
                ),
              ),
            ),
            // Profile avatar
            Obx(() {
              final authCtrl = Get.find<AuthController>();
              final profile = authCtrl.profile.value;
              final auth = authCtrl.currentAuth.value;
              final name = profile?.fullName ?? auth?.fullName ?? '';
              final imageUrl = profile?.profileImageUrl;
              final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
              return Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kPrimary.withAlpha(30),
                        border: Border.all(
                          color: kPrimary.withAlpha(80),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    letter,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimary,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  letter,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: kPrimary,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name.isEmpty ? '—' : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : kTextDark,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
