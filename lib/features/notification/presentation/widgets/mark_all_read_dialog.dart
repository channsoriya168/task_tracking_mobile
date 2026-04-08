import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/notification/presentation/controllers/notification_controller.dart';

class MarkAllReadDialog extends StatelessWidget {
  const MarkAllReadDialog({super.key, required this.isDark});

  final bool isDark;

  static Future<void> show(
    BuildContext context,
    NotificationController controller,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => MarkAllReadDialog(isDark: isDark),
    );

    if (confirmed == true) {
      await controller.markAllAsRead();
      controller.showUnreadOnly.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF1E1E38) : Colors.white,
      title: Text(
        'notif_mark_all_confirm_title'.tr,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
      content: Text(
        'notif_mark_all_confirm_msg'.tr,
        style: TextStyle(
          color: isDark ? Colors.white60 : const Color(0xFF64748B),
          height: 1.5,
          fontSize: 14,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'dialog_cancel'.tr,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF4757),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            'notif_mark_all_confirm_btn'.tr,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}