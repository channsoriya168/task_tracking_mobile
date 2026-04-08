import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/enums/user_role.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/notification/domain/entities/notification_entity.dart';
import 'package:task_tracking_mobile/features/notification/presentation/controllers/notification_controller.dart';
import 'package:task_tracking_mobile/features/notification/presentation/widgets/notification_tile.dart';
import 'package:task_tracking_mobile/features/task/domain/repositories/task_item_repository.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/employee_task_controller.dart';
import 'package:task_tracking_mobile/routes/app_routes.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/show_task_detail_sheet.dart';

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
          child: Builder(
            builder: (context) {
              final listItems = _buildListItems(controller.notifications);
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                itemCount: listItems.length,
                itemBuilder: (context, index) {
                  final item = listItems[index];

                  if (item.header != null) {
                    return Padding(
                      padding: EdgeInsets.only(
                        top: index == 0 ? 4 : 10,
                        bottom: 8,
                      ),
                      child: Text(
                        item.header!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF334155),
                          letterSpacing: 0.2,
                        ),
                      ),
                    );
                  }

                  final notification = item.notification!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child:
                        NotificationTile(
                          notification: notification,
                          onTap: () async {
                            if (!notification.isRead) {
                              controller.markAsRead(notification.id);
                            }
                            if (notification.taskId != null) {
                              await _openTaskDetail(
                                context,
                                notification.taskId!,
                              );
                            }
                          },
                          onDismissed: () {
                            controller.deleteNotification(notification.id);
                          },
                        ).animate().fadeIn(
                          duration: 300.ms,
                          delay: (item.animationIndex * 50).ms,
                        ),
                  );
                },
              );
            },
          ),
        );
      }),
    );
  }

  List<_NotificationListItem> _buildListItems(
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

      items.add(
        _NotificationListItem.notification(notification, animationIndex),
      );
      animationIndex++;
    }

    return items;
  }

  String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (DateUtils.isSameDay(day, today)) return 'Today';
    if (DateUtils.isSameDay(day, yesterday)) return 'Yesterday';

    const months = [
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

    return '${months[day.month - 1]} ${day.day}, ${day.year}';
  }

  Future<void> _openTaskDetail(BuildContext context, String taskId) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    TaskItemRepository? repo;
    try {
      repo = Get.find<TaskItemRepository>();
    } catch (_) {
      return;
    }

    // Show loading while fetching task
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final task = await repo.fetchTaskItemById(taskId);
      if (Get.isDialogOpen ?? false) Get.back();

      if (!context.mounted) return;

      final role = Get.find<AuthController>().role;
      if (role == UserRole.employee) {
        if (Get.isRegistered<EmployeeTaskController>()) {
          Get.find<EmployeeTaskController>().prepareTaskDetail(taskId);
        }
        Get.toNamed(
          AppRoutes.taskDetail,
          arguments: {'task': task, 'isDark': isDark, 'readOnly': false},
        );
      } else {
        await showTaskDetailSheet(
          context,
          isDark,
          task,
          fetchDetail: repo.fetchTaskItemById,
        );
      }
    } catch (_) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Error',
        'Could not load task details.',
        backgroundColor: const Color(0xFFFF4757),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}

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
