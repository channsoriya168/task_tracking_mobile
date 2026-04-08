import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/notification/domain/entities/notification_entity.dart';
import 'package:task_tracking_mobile/features/notification/presentation/widgets/delete_notification_dialog.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final Future<void> Function() onTap;
  final VoidCallback onDismissed;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRead = notification.isRead;
    final message = notification.message;
    final accent = _accentColor;
    final cardColor = isDark
        ? (isRead ? kBgDark : const Color(0xFF1A2238))
        : (isRead ? kBgLight : const Color(0xFFF6FAFF));
    final borderColor = isDark
        ? Colors.white.withValues(alpha: isRead ? 0.07 : 0.12)
        : (isRead ? const Color(0xFFE2E8F0) : accent.withValues(alpha: 0.28));

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => DeleteNotificationDialog.show(context),
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF3D5A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_icon, color: accent, size: 22),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (notification.type == NotificationType.taskCommented &&
                        message != null &&
                        message.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: isDark ? 0.12 : 0.07),
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                            left: BorderSide(color: accent, width: 3),
                          ),
                        ),
                        child: Text(
                          message,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.80)
                                : const Color(0xFF334155),
                            height: 1.4,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ] else if (message != null && message.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.72)
                              : const Color(0xFF475569),
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _TypeBadge(
                        type: notification.type,
                        accent: accent,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: isDark
                              ? Colors.white54
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _relativeTime(notification.createdAt),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isDark
                                ? Colors.white54
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!isRead)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────
  IconData get _icon {
    switch (notification.type) {
      case NotificationType.taskStatusChanged:
        return Icons.swap_horiz_rounded;
      case NotificationType.taskCommented:
        return Icons.comment_rounded;
      case NotificationType.taskDueDateApproaching:
        return Icons.access_time_rounded;
      case NotificationType.taskAddedToGroup:
        return Icons.group_add_rounded;
      case NotificationType.taskCompleted:
        return Icons.check_circle_rounded;
    }
  }

  Color get _accentColor {
    switch (notification.type) {
      case NotificationType.taskStatusChanged:
        return const Color(0xFF0EA5E9);
      case NotificationType.taskCommented:
        return const Color(0xFF8B5CF6);
      case NotificationType.taskDueDateApproaching:
        return const Color(0xFFF97316);
      case NotificationType.taskAddedToGroup:
        return const Color(0xFF14B8A6);
      case NotificationType.taskCompleted:
        return const Color(0xFF22C55E);
    }
  }

  String _relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'notif_time_just_now'.tr;
    if (diff.inMinutes < 60) {
      return 'notif_time_minutes'.trParams({'count': '${diff.inMinutes}'});
    }
    if (diff.inHours < 24) {
      return 'notif_time_hours'.trParams({'count': '${diff.inHours}'});
    }
    if (diff.inDays < 7) {
      return 'notif_time_days'.trParams({'count': '${diff.inDays}'});
    }
    if (diff.inDays < 30) {
      return 'notif_time_weeks'.trParams({
        'count': '${(diff.inDays / 7).floor()}',
      });
    }
    return 'notif_time_months'.trParams({
      'count': '${(diff.inDays / 30).floor()}',
    });
  }
}

class _TypeBadge extends StatelessWidget {
  final NotificationType type;
  final Color accent;
  final bool isDark;

  const _TypeBadge({
    required this.type,
    required this.accent,
    required this.isDark,
  });

  (IconData, String) get _label {
    switch (type) {
      case NotificationType.taskCommented:
        return (Icons.comment_rounded, 'notif_type_comment'.tr);
      case NotificationType.taskStatusChanged:
        return (Icons.swap_horiz_rounded, 'notif_type_status_changed'.tr);
      case NotificationType.taskDueDateApproaching:
        return (Icons.warning_amber_rounded, 'notif_type_due_soon'.tr);
      case NotificationType.taskAddedToGroup:
        return (Icons.group_add_rounded, 'notif_type_added_to_team'.tr);
      case NotificationType.taskCompleted:
        return (Icons.check_circle_rounded, 'notif_type_completed'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, label) = _label;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.15 : 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.35 : 0.30),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: accent),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: accent,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
