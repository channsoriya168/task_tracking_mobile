import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/notification/presentation/controllers/notification_controller.dart';
import 'package:task_tracking_mobile/features/notification/presentation/widgets/notification_tile.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Obx(() {
            if (controller.unreadCount.value == 0) {
              return const SizedBox.shrink();
            }
            return IconButton(
              onPressed: controller.markAllAsRead,
              icon: const Icon(Icons.done_all_rounded),
              tooltip: 'Mark all as read',
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty &&
            controller.notifications.isEmpty) {
          return Center(
            child: Padding(
              padding: kPagePaddingWithBottom,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: isDark ? Colors.white38 : kTextMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white54 : kTextMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: controller.fetchNotifications,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 64,
                  color: isDark ? Colors.white24 : const Color(0xFFD0D0E0),
                ),
                const SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white38 : kTextMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You'll see task updates and reminders here.",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white24 : const Color(0xFFB0B0C0),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchNotifications();
            await controller.fetchUnreadCount();
          },
          color: kPrimary,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            itemCount: controller.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return NotificationTile(
                notification: notification,
                onTap: () {
                  if (!notification.isRead) {
                    controller.markAsRead(notification.id);
                  }
                },
                onDismissed: () {
                  controller.deleteNotification(notification.id);
                },
              ).animate().fadeIn(
                    duration: 300.ms,
                    delay: (index * 50).ms,
                  );
            },
          ),
        );
      }),
    );
  }
}
