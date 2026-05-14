import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';

class NotificationEmptyWidget extends StatelessWidget {
  final bool isFiltered;

  const NotificationEmptyWidget({this.isFiltered = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF2A2A4A), const Color(0xFF1E1E38)]
                      : [const Color(0xFFEEECFF), const Color(0xFFE0DDFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Icon(
                isFiltered
                    ? Icons.mark_email_read_rounded
                    : Icons.notifications_none_rounded,
                size: 42,
                color: isDark ? kPrimary.withValues(alpha: 0.75) : kPrimary,
              ),
            ).animate().scale(
              duration: 420.ms,
              curve: Curves.elasticOut,
              begin: const Offset(0.7, 0.7),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered ? 'notif_unread_empty'.tr : 'notif_all_caught_up'.tr,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'notif_unread_empty_sub'.tr
                  : 'notif_all_caught_up_sub'.tr,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white38 : kTextMuted,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
