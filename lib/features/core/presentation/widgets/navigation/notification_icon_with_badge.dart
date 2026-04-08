import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/notification/presentation/controllers/notification_controller.dart';

class NotificationIconWithBadge extends StatelessWidget {
  const NotificationIconWithBadge({
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
        size: 21,
        color: isSelected ? Colors.white : inactiveColor,
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
            size: 21,
            color: isSelected ? Colors.white : inactiveColor,
          ),
          if (count > 0)
            Positioned(
              right: -7,
              top: -5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white.withAlpha(60)
                        : Colors.white,
                    width: 1.2,
                  ),
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
