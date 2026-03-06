import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/staff/data/models/task_model.dart';

// ── Task List Card ───────────────────────────────────────────
class TaskListCard extends StatelessWidget {
  const TaskListCard({super.key, required this.isDark, required this.task});

  final bool isDark;
  final TaskModel task;

  String _formatDate(DateTime d) {
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
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = kStatusColors[task.statusLabel] ?? kPrimary;
    final priorityColor = kPriorityColors[task.priorityLabel] ?? kTextMuted;

    final cardBg = isDark ? kCardDark : Colors.white;
    final titleColor = isDark ? Colors.white : kTextDark;
    final mutedColor = isDark ? Colors.grey[500]! : kTextMuted;

    final statusIcon = switch (task.status) {
      TaskStatus.todo => Icons.radio_button_unchecked_rounded,
      TaskStatus.inProgress => Icons.sync_rounded,
      TaskStatus.done => Icons.check_circle_rounded,
      TaskStatus.fail => Icons.cancel_rounded,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Status icon box
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(statusIcon, color: statusColor, size: 20),
            ),

            const SizedBox(width: 12),

            // Title + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        task.category,
                        style: TextStyle(fontSize: 11, color: mutedColor),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          '·',
                          style: TextStyle(color: mutedColor, fontSize: 11),
                        ),
                      ),
                      Text(
                        task.dueDate != null
                            ? (task.isOverdue
                                ? 'Overdue'
                                : _formatDate(task.dueDate!))
                            : 'No due date',
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              task.isOverdue ? kHighPriority : mutedColor,
                          fontWeight: task.isOverdue
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: priorityColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Trailing action
            if (task.status == TaskStatus.todo)
              const _AcceptButton()
            else if (task.acceptedBy != null)
              _AcceptedByChip(
                name: task.acceptedBy!,
                avatarUrl: task.acceptedByAvatar,
                isDark: isDark,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Accepted By Chip ─────────────────────────────────────────
class _AcceptedByChip extends StatelessWidget {
  const _AcceptedByChip({
    required this.name,
    required this.isDark,
    this.avatarUrl,
  });

  final String name;
  final bool isDark;
  final String? avatarUrl;

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white70 : kPrimary;
    final bg = isDark ? Colors.white10 : kPrimary.withAlpha(15);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: kPrimary.withAlpha(40),
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl!)
                : null,
            child: avatarUrl == null
                ? Text(
                    _initials,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Accept Button ───────────────────────────────────────────
class _AcceptButton extends StatelessWidget {
  const _AcceptButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kPrimary, Color(0xFF8B5CF6)]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withAlpha(80),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_rounded, size: 14, color: Colors.white),
            SizedBox(width: 5),
            Text(
              'Accept',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
