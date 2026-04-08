import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/notification/presentation/controllers/notification_controller.dart';
import 'package:task_tracking_mobile/features/notification/presentation/widgets/filter_pill_widget.dart';
import 'package:task_tracking_mobile/features/notification/presentation/widgets/notification_empty_widget.dart';
import 'package:task_tracking_mobile/features/notification/presentation/widgets/notification_error_state_widget.dart';
import 'package:task_tracking_mobile/features/notification/presentation/widgets/notification_list_widget.dart';
import 'package:task_tracking_mobile/features/notification/presentation/widgets/mark_all_read_dialog.dart';
import 'package:task_tracking_mobile/features/notification/presentation/widgets/notification_skeletion_widget.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: Column(
        children: [
          // ── Custom header ─────────────────────────────────────────────────
          Container(
            color: isDark ? kBgDark : kBgLight,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: kPagePaddingHorizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title + subtitle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'notification_title'.tr,
                          style: AppTextStyles.appBarTitle(
                            color: isDark ? Colors.white : kTextDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Obx(() {
                          final count = controller.unreadCount.value;
                          return Text(
                            count == 0
                                ? 'notif_all_caught_up'.tr
                                : 'notif_unread_count'.trParams({
                                    'count': '$count',
                                  }),
                            style: TextStyle(
                              color: isDark
                                  ? kTextLight.withValues(alpha: 0.70)
                                  : kTextDark.withValues(alpha: 0.70),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              fontFamily: Get.locale?.languageCode == 'km'
                                  ? 'Siemreap'
                                  : 'Kantumruy Pro',
                            ),
                          );
                        }),
                      ],
                    ),
                    const Spacer(),
                    // Mark all button
                    Obx(() {
                      if (controller.unreadCount.value == 0) {
                        return const SizedBox.shrink();
                      }
                      return GestureDetector(
                        onTap: () =>
                            MarkAllReadDialog.show(context, controller),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? kTextDark.withValues(alpha: 0.18)
                                : kTextLight.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: kPrimary, width: 1),
                          ),
                          child: Text(
                            'notif_mark_all'.tr,
                            style: TextStyle(
                              color: isDark ? kTextLight : kTextDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          //filter pills
          Obx(
            () => Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  FilterPillWidget(
                    label: 'notif_filter_all'.tr,
                    isSelected: !controller.showUnreadOnly.value,
                    isDark: isDark,
                    onTap: () => controller.showUnreadOnly.value = false,
                  ),
                  const SizedBox(width: 8),
                  FilterPillWidget(
                    label: 'notif_filter_unread'.tr,
                    isSelected: controller.showUnreadOnly.value,
                    isDark: isDark,
                    onTap: () => controller.showUnreadOnly.value = true,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final all = controller.notifications;
              final displayed = controller.showUnreadOnly.value
                  ? all.where((n) => !n.isRead).toList()
                  : all;

              if (controller.isLoading.value && all.isEmpty) {
                return NotificationSkeletonWidget(isDark: isDark);
              }

              if (controller.errorMessage.isNotEmpty && all.isEmpty) {
                return NotificationErrorStateWidget(
                  message: controller.errorMessage.value,
                  onRetry: controller.fetchNotifications,
                );
              }

              if (displayed.isEmpty) {
                return NotificationEmptyWidget(
                  isFiltered: controller.showUnreadOnly.value,
                );
              }

              return NotificationListWidget(
                controller: controller,
                notifications: displayed,
                isDark: isDark,
              );
            }),
          ),
        ],
      ),
    );
  }
}
