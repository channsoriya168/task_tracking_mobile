import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/features/notification/domain/entities/notification_entity.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
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

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4757),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isRead
                ? (isDark ? const Color(0xFF1A1A2E) : Colors.white)
                : (isDark
                    ? const Color(0xFF1A1A2E).withValues(alpha: 0.8)
                    : const Color(0xFFF0EEFF)),
            borderRadius: BorderRadius.circular(16),
            border: isRead
                ? null
                : Border.all(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                    width: 1,
                  ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon ────────────────────────────────
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon, color: _iconColor, size: 22),
              ),
              const SizedBox(width: 14),

              // ── Content ─────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (notification.message != null &&
                        notification.message!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        notification.message!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF8E8EA0),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      _relativeTime(notification.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: isDark
                            ? Colors.white38
                            : const Color(0xFFB0B0C0),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Unread dot ──────────────────────────
              if (!isRead)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6C63FF),
                      shape: BoxShape.circle,
                    ),
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

  Color get _iconColor {
    switch (notification.type) {
      case NotificationType.taskStatusChanged:
        return const Color(0xFF6C63FF);
      case NotificationType.taskCommented:
        return const Color(0xFF3498DB);
      case NotificationType.taskDueDateApproaching:
        return const Color(0xFFFFA502);
      case NotificationType.taskAddedToGroup:
        return const Color(0xFF2ED573);
      case NotificationType.taskCompleted:
        return const Color(0xFF2ED573);
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
