import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';

class NotificationErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const NotificationErrorStateWidget({
    required this.message,
    required this.onRetry,
  });

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
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: const Color(
                  0xFFFF4757,
                ).withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 38,
                color: Color(0xFFFF4757),
              ),
            ).animate().scale(
              duration: 420.ms,
              curve: Curves.elasticOut,
              begin: const Offset(0.7, 0.7),
            ),
            const SizedBox(height: 20),
            Text(
              'notif_error_title'.tr,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white38 : kTextMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
