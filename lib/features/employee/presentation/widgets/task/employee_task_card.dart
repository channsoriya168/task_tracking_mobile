import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';

class EmployeeTaskCard extends StatelessWidget {
  const EmployeeTaskCard({
    super.key,
    required this.task,
    required this.isDark,
  });

  final TaskItem task;
  final bool isDark;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _fmt(DateTime dt) => '${dt.day} ${_months[dt.month - 1]}';

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? kCardDark : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final mutedColor = isDark
        ? Colors.white.withValues(alpha: 0.4)
        : const Color(0xFF9CA3AF);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);

    final statusColor = task.status.color;
    final priorityColor = task.priority.color;

    final isOverdue =
        task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        task.status.name.toLowerCase() != 'completed' &&
        task.status.name.toLowerCase() != 'cancelled';

    final assignee = task.assignedToName ?? task.createdByEmployeeName;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: title + status pill ──────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(
                label: task.status.name,
                color: statusColor,
                isDark: isDark,
              ),
            ],
          ),

          // ── Row 2: description ──────────────────────────
          if ((task.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              task.description!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: mutedColor, height: 1.4),
            ),
          ],

          const SizedBox(height: 10),

          // ── Row 3: metadata ─────────────────────────────
          Row(
            children: [
              // Due date
              if (task.dueDate != null) ...[
                Icon(
                  isOverdue
                      ? Icons.warning_amber_rounded
                      : Icons.calendar_today_rounded,
                  size: 11,
                  color: isOverdue ? kHighPriority : mutedColor,
                ),
                const SizedBox(width: 3),
                Text(
                  _fmt(task.dueDate!),
                  style: TextStyle(
                    fontSize: 11,
                    color: isOverdue ? kHighPriority : mutedColor,
                    fontWeight:
                        isOverdue ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                _MetaDot(mutedColor),
              ],
              // Priority dot + name
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: priorityColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                task.priority.name,
                style: TextStyle(fontSize: 11, color: mutedColor),
              ),
              // Label or group
              if ((task.labelName ?? task.groupName) != null) ...[
                _MetaDot(mutedColor),
                Flexible(
                  child: Text(
                    task.labelName ?? task.groupName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: mutedColor),
                  ),
                ),
              ],
              const Spacer(),
              if (assignee != null) _Avatar(name: assignee, isDark: isDark),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Status pill ─────────────────────────────────────────────────
class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
    required this.isDark,
  });
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Metadata separator dot ──────────────────────────────────────
class _MetaDot extends StatelessWidget {
  const _MetaDot(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ── Assignee avatar ─────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.isDark});
  final String name;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.06),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white70 : const Color(0xFF374151),
        ),
      ),
    );
  }
}
