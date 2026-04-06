import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/routes/app_routes.dart';
import 'package:task_tracking_mobile/features/notification/presentation/controllers/notification_controller.dart';

/// A bell icon with an unread badge — drop it into any AppBar's actions.
class NotificationBellWidget extends StatelessWidget {
  const NotificationBellWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final count = controller.unreadCount.value;
      return IconButton(
        onPressed: () {
          Get.toNamed(AppRoutes.notifications);
        },
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              count > 0
                  ? Icons.notifications_rounded
                  : Icons.notifications_none_rounded,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              size: 26,
            ),
            if (count > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4757),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4757).withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 16,
                  ),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
