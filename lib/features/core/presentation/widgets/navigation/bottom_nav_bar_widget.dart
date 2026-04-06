import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:task_tracking_mobile/features/employee/data/models/nav_item.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';

class BottomNavBarWidget extends StatelessWidget {
  const BottomNavBarWidget({super.key, required this.items});

  final List<NavItem> items;

  @override
  Widget build(BuildContext context) {
    final NavigationController navController = Get.find();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(
      () => Container(
        margin: kNavMargin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey[900]!.withAlpha(230)
                    : Colors.white.withAlpha(240),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withAlpha(18),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    spreadRadius: -2,
                    offset: const Offset(0, 6),
                    color: Colors.black.withAlpha(isDark ? 100 : 30),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  child: Row(
                    children: List.generate(items.length, (i) {
                      final isSelected = navController.selectedIndex.value == i;
                      return Expanded(
                        child: _NavItem(
                          item: items[i],
                          isSelected: isSelected,
                          isDark: isDark,
                          onTap: () => navController.changePage(i),
                        ),
                      );
                    }),
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final NavItem item;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inactiveColor = isDark ? Colors.grey[500]! : Colors.grey[500]!;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Icon indicator ───────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOutCubic,
            width: 52,
            height: 30,
            decoration: BoxDecoration(
              color: isSelected && item.label != 'Profile'
                  ? kPrimary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: item.label == 'Profile'
                  ? _ProfileAvatar(isSelected: isSelected)
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        item.icon,
                        key: ValueKey(isSelected),
                        size: 20,
                        color: isSelected ? Colors.white : inactiveColor,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 3),
          // ── Label ────────────────────────────────────────────
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 280),
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected ? kPrimary : inactiveColor,
              letterSpacing: isSelected ? 0.2 : 0,
            ),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final authCtrl = Get.find<AuthController>();
      final profile = Get.find<ProfileController>().profile.value;
      final auth = authCtrl.currentAuth.value;
      final name = profile?.fullName ?? auth?.fullName ?? '';
      final imageUrl = profile?.profileImageUrl;
      final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';

      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? Colors.white.withAlpha(40)
              : kPrimary.withAlpha(25),
          border: Border.all(
            color: isSelected ? kPrimary : kPrimary.withAlpha(100),
            width: isSelected ? 2 : 1.5,
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
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : kPrimary,
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color.fromARGB(255, 172, 20, 20)
                          : kPrimary,
                    ),
                  ),
                ),
        ),
      );
    });
  }
}
