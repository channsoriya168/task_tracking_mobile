import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/notification/presentation/controllers/notification_controller.dart';
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
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1C1C2E).withAlpha(235)
                    : Colors.white.withAlpha(245),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withAlpha(12)
                      : Colors.black.withAlpha(10),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 32,
                    spreadRadius: -4,
                    offset: const Offset(0, 8),
                    color: Colors.black.withAlpha(isDark ? 120 : 35),
                  ),
                  BoxShadow(
                    blurRadius: 8,
                    spreadRadius: -2,
                    offset: const Offset(0, 2),
                    color: kPrimary.withAlpha(isDark ? 30 : 15),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 10,
                  ),
                  child: Row(
                    children: List.generate(items.length, (i) {
                      final isSelected =
                          navController.selectedIndex.value == i;
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
    final inactiveColor =
        isDark ? Colors.grey.shade500 : const Color(0xFF9E9E9E);
    final isNotificationItem = item.icon == Icons.notifications_rounded;
    final isProfileItem = item.label == 'Profile';

    Widget iconWidget;
    if (isProfileItem) {
      iconWidget = _ProfileAvatar(isSelected: isSelected);
    } else if (isNotificationItem) {
      iconWidget = _NotificationIconWithBadge(
        icon: item.icon,
        isSelected: isSelected,
        inactiveColor: inactiveColor,
      );
    } else {
      iconWidget = Icon(
        item.icon,
        size: 22,
        color: isSelected ? kPrimary : inactiveColor,
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? kPrimary.withAlpha(isDark ? 35 : 22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: KeyedSubtree(
                key: ValueKey('${item.icon}_$isSelected'),
                child: iconWidget,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? kPrimary : inactiveColor,
                letterSpacing: isSelected ? 0.3 : 0,
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationIconWithBadge extends StatelessWidget {
  const _NotificationIconWithBadge({
    required this.icon,
    required this.isSelected,
    required this.inactiveColor,
  });

  final IconData icon;
  final bool isSelected;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NotificationController>()) {
      return Icon(
        icon,
        size: 22,
        color: isSelected ? kPrimary : inactiveColor,
      );
    }

    final notificationController = Get.find<NotificationController>();

    return Obx(() {
      final count = notificationController.unreadCount.value;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            icon,
            size: 22,
            color: isSelected ? kPrimary : inactiveColor,
          ),
          if (count > 0)
            Positioned(
              right: -6,
              top: -5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                constraints:
                    const BoxConstraints(minWidth: 15, minHeight: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    });
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

      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? kPrimary.withAlpha(18) : Colors.transparent,
          border: Border.all(
            color: isSelected ? kPrimary : kPrimary.withAlpha(80),
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
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: kPrimary,
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
                    ),
                  ),
                ),
        ),
      );
    });
  }
}