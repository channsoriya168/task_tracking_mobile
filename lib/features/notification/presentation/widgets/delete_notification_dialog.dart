import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeleteNotificationDialog extends StatelessWidget {
  const DeleteNotificationDialog({super.key, required this.isDark});

  final bool isDark;

  static Future<bool> show(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => DeleteNotificationDialog(isDark: isDark),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF1E1E38) : Colors.white,
      title: Text(
        'notif_delete_title'.tr,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
      content: Text(
        'notif_delete_msg'.tr,
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
            'action_delete'.tr,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}