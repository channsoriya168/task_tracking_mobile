import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/features/notification/domain/entities/notification_entity.dart';

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
    final accent = _accentColor;
    final cardColor = isDark
        ? (isRead ? const Color(0xFF151B2E) : const Color(0xFF1A2238))
        : (isRead ? Colors.white : const Color(0xFFF6FAFF));
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : accent.withValues(alpha: isRead ? 0.08 : 0.22);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.24)
                    : const Color(0xFF0F172A).withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isRead)
                Container(
                  width: 4,
                  height: 56,
                  margin: const EdgeInsets.only(right: 12, top: 2),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.18),
                      accent.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.28),
                    width: 1,
                  ),
                ),
                child: Icon(_icon, color: accent, size: 22),
              ),
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
                    if (notification.message != null &&
                        notification.message!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        notification.message!,
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
                    const SizedBox(height: 10),
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

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}w ago';
    }
    return '${(diff.inDays / 30).floor()}mo ago';
  }
}
