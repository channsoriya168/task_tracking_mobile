import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/notification/domain/entities/notification_entity.dart';
import 'package:task_tracking_mobile/features/notification/presentation/controllers/notification_controller.dart';
import 'package:task_tracking_mobile/features/notification/presentation/widgets/date_section_widget.dart';
import 'package:task_tracking_mobile/features/notification/presentation/widgets/notification_tile.dart';

class NotificationListWidget extends StatelessWidget {
  final NotificationController controller;
  final List<NotificationEntity> notifications;
  final bool isDark;

  const NotificationListWidget({
    required this.controller,
    required this.notifications,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final items = _buildNotificationListItems(notifications);

    return RefreshIndicator(
      onRefresh: () async {
        await controller.fetchNotifications();
        await controller.fetchUnreadCount();
      },
      color: kPrimary,
      backgroundColor: isDark ? kBgDark : kBgLight,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final header = item.header;

          if (header != null) {
            return DateSectionWidget(
              label: header,
              isFirst: index == 0,
              isDark: isDark,
            );
          }

          final notification = item.notification;
          if (notification == null) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NotificationTile(
              notification: notification,
              onTap: () async {
                if (!notification.isRead) {
                  controller.markAsRead(notification.id);
                }
                final taskId = notification.taskId;
                if (taskId != null && taskId.isNotEmpty) {
                  final initialTab = notification.type ==
                      NotificationType.taskCommented
                      ? 1
                      : 0;
                  await controller.openTaskDetail(taskId, initialTab: initialTab);
                }
              },
              onDismissed: () {
                controller.deleteNotification(notification.id);
              },
            ),
          );
        },
      ),
    );
  }
}

List<_NotificationListItem> _buildNotificationListItems(
  List<NotificationEntity> notifications,
) {
  final items = <_NotificationListItem>[];
  DateTime? currentDay;
  var animationIndex = 0;

  for (final notification in notifications) {
    final createdAt = notification.createdAt;
    final day = DateTime(createdAt.year, createdAt.month, createdAt.day);

    if (currentDay == null || !DateUtils.isSameDay(currentDay, day)) {
      items.add(_NotificationListItem.header(_dayLabel(day)));
      currentDay = day;
    }

    items.add(_NotificationListItem.notification(notification, animationIndex));
    animationIndex++;
  }

  return items;
}

String _dayLabel(DateTime day) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  if (DateUtils.isSameDay(day, today)) return 'notif_today'.tr;
  if (DateUtils.isSameDay(day, yesterday)) return 'notif_yesterday'.tr;

  const monthsEn = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  const monthsKm = [
    'មករា',
    'កុម្ភៈ',
    'មីនា',
    'មេសា',
    'ឧសភា',
    'មិថុនា',
    'កក្កដា',
    'សីហា',
    'កញ្ញា',
    'តុលា',
    'វិច្ឆិកា',
    'ធ្នូ',
  ];
  final months = Get.locale?.languageCode == 'km' ? monthsKm : monthsEn;
  return '${months[day.month - 1]} ${day.day}, ${day.year}';
}

// ── List item model ───────────────────────────────────────────────────────────

class _NotificationListItem {
  final String? header;
  final NotificationEntity? notification;
  final int animationIndex;

  const _NotificationListItem.header(this.header)
    : notification = null,
      animationIndex = 0;

  const _NotificationListItem.notification(
    this.notification,
    this.animationIndex,
  ) : header = null;
}
