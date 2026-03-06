import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/staff/data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final bool highlighted;
  final VoidCallback? onAccept;
  final VoidCallback? onFinish;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
    this.highlighted = false,
    this.onAccept,
    this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOverdue = task.isOverdue;

    // Highlighted cards (active in-progress) get a very subtle status tint
    final cardBg = highlighted
        ? (isDark
            ? kLowPriority.withValues(alpha: 0.10)
            : kLowPriority.withValues(alpha: 0.05))
        : (isDark ? kCardDark : Colors.white);

    final borderColor = highlighted
        ? kLowPriority.withValues(alpha: isDark ? 0.35 : 0.40)
        : (isDark
            ? Colors.white.withValues(alpha: 0.18)
            : const Color(0xFFD1D5DB));

    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final mutedColor = isDark ? Colors.white38 : const Color(0xFF9CA3AF);

    // Progress
    final done = task.progressItems.where((s) => s.startsWith('[x]')).length;
    final total = task.progressItems.length;
    final progressValue = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);

    return Dismissible(
      key: Key(task.id),
      direction: task.status == TaskStatus.done
          ? DismissDirection.none
          : DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: kHighPriority.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kHighPriority.withValues(alpha: 0.2)),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: kHighPriority, size: 20),
      ),
      child: GestureDetector(
        onTap: task.status != TaskStatus.done ? onTap : null,
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Meta row ───────────────────────────
                      Row(
                        children: [
                          Text(
                            task.category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: _categoryColor(task.category),
                            ),
                          ),
                          const Spacer(),
                          _PriorityDot(task: task),
                          const SizedBox(width: 6),
                          if (task.status != TaskStatus.done)
                            _TaskMenu(
                              onEdit: onTap,
                              onDelete: onDelete,
                              isDark: isDark,
                              mutedColor: mutedColor,
                            ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ── Title ──────────────────────────────
                      Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Divider ────────────────────────────
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.10)
                            : const Color(0xFFE5E7EB),
                      ),

                      const SizedBox(height: 12),

                      // ── Footer ─────────────────────────────
                      Row(
                        children: [
                          Icon(
                            isOverdue
                                ? Icons.error_outline_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 13,
                            color: isOverdue
                                ? kHighPriority
                                : task.statusColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _footerLabel(isOverdue),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color:
                                  isOverdue ? kHighPriority : mutedColor,
                            ),
                          ),
                          const Spacer(),
                          if (task.acceptedBy != null) ...[
                            _AssigneeAvatar(name: task.acceptedBy!),
                            const SizedBox(width: 8),
                          ],
                          _ActionWidget(
                            task: task,
                            onAccept: onAccept,
                            onFinish: onFinish,
                            onDetail: onTap,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Progress strip ─────────────────────────
                if (task.status == TaskStatus.inProgress)
                  _ProgressStrip(value: progressValue, isDark: isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _categoryColor(String category) {
    switch (category) {
      case 'Meeting':       return const Color(0xFF1976D2);
      case 'Engineering':   return const Color(0xFF6B3FA0);
      case 'Design':        return const Color(0xFFD81B60);
      case 'Research':      return const Color(0xFF00838F);
      case 'Documentation': return const Color(0xFFF57C00);
      case 'Marketing':     return const Color(0xFF8E24AA);
      case 'Maintenance':   return const Color(0xFF546E7A);
      default:              return kTextMuted;
    }
  }

  String _footerLabel(bool isOverdue) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    if (task.dueDate == null) return task.statusLabel;
    final d = task.dueDate!;
    final datePart = '${d.day} ${m[d.month - 1]}';
    return isOverdue ? 'Overdue · $datePart' : '${task.statusLabel} · $datePart';
  }
}

// ── Sub-widgets ────────────────────────────────────────────────

class _PriorityDot extends StatelessWidget {
  const _PriorityDot({required this.task});
  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    final color = task.priorityColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          task.priorityLabel,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TaskMenu extends StatelessWidget {
  const _TaskMenu({
    required this.onEdit,
    required this.onDelete,
    required this.isDark,
    required this.mutedColor,
  });
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDark;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _show(context),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(Icons.more_horiz_rounded, size: 18, color: mutedColor),
      ),
    );
  }

  void _show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? kSurfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.edit_outlined,
                  color: isDark ? Colors.white70 : kTextDark),
              title: Text('Edit',
                  style:
                      TextStyle(color: isDark ? Colors.white : kTextDark)),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: kHighPriority),
              title: const Text('Delete',
                  style: TextStyle(color: kHighPriority)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _AssigneeAvatar extends StatelessWidget {
  const _AssigneeAvatar({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = name
        .trim()
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0].toUpperCase())
        .take(2)
        .join();
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: kPrimary.withValues(alpha: isDark ? 0.25 : 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: kPrimary.withValues(alpha: 0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: kPrimary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ActionWidget extends StatelessWidget {
  const _ActionWidget({
    required this.task,
    required this.onAccept,
    required this.onFinish,
    required this.onDetail,
  });
  final TaskModel task;
  final VoidCallback? onAccept;
  final VoidCallback? onFinish;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    if (task.status == TaskStatus.todo && onAccept != null) {
      return _ActionButton(label: 'Accept', onTap: onAccept!);
    }
    if (task.status == TaskStatus.inProgress && onFinish != null) {
      return _ActionButton(label: 'Progress', onTap: onFinish!);
    }
    if (task.status == TaskStatus.done) {
      return _ActionButton(label: 'Detail', onTap: onDetail);
    }
    return const SizedBox.shrink();
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: kPrimary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ProgressStrip extends StatelessWidget {
  const _ProgressStrip({required this.value, required this.isDark});
  final double value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      child: LinearProgressIndicator(
        value: value,
        backgroundColor:
            isDark ? Colors.white12 : kPrimary.withValues(alpha: 0.08),
        valueColor: AlwaysStoppedAnimation(
          value >= 1.0 ? kLowPriority : kPrimary,
        ),
        borderRadius: BorderRadius.zero,
      ),
    );
  }
}
