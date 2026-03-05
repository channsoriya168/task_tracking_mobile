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

    // ── Themed colours ─────────────────────────────────────
    final Color cardBg = highlighted
        ? const Color(0xFF4CAF50)
        : (isDark ? kCardDark : Colors.white);
    final Color titleColor =
        highlighted ? Colors.white : (isDark ? Colors.white : kTextDark);
    final Color mutedColor = highlighted
        ? Colors.white.withOpacity(0.75)
        : (isDark ? Colors.white54 : kTextMuted);
    final Color accentColor =
        highlighted ? Colors.white : task.priorityColor;

    final bool isOverdue = task.isOverdue;

    return Dismissible(
      key: Key(task.id),
      direction: task.status == TaskStatus.done
          ? DismissDirection.none
          : DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: kItemSpacingRightLarge,
        decoration: BoxDecoration(
          color: kHighPriority.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: kHighPriority),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: highlighted
                ? null
                : Border(
                    left: BorderSide(
                      color: task.priorityColor,
                      width: 3,
                    ),
                  ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: kContentPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header: title + menu ──────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                            height: 1.3,
                          ),
                        ),
                      ),
                      if (task.status != TaskStatus.done) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showMenu(context),
                          child: Icon(
                            Icons.more_horiz_rounded,
                            color: mutedColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ── Tags: category + priority ─────────────
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _categoryTag(highlighted, isDark),
                      _priorityTag(highlighted),
                      _statusTag(highlighted, isDark),
                    ],
                  ),

                  // ── Progress bar (inProgress only) ────────
                  if (task.status == TaskStatus.inProgress) ...[
                    const SizedBox(height: 12),
                    _progressBar(highlighted, isDark, mutedColor),
                  ],

                  const SizedBox(height: 12),

                  // ── Footer: date + accepted by + action ───
                  Row(
                    children: [
                      Icon(
                        isOverdue && !highlighted
                            ? Icons.warning_amber_rounded
                            : Icons.calendar_today_outlined,
                        size: 12,
                        color: isOverdue && !highlighted
                            ? kHighPriority
                            : mutedColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.dueDate != null
                            ? _formatDate(task.dueDate!)
                            : 'No date',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue && !highlighted
                              ? kHighPriority
                              : mutedColor,
                          fontWeight: isOverdue && !highlighted
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      if (task.acceptedBy != null) ...[
                        const SizedBox(width: 8),
                        _acceptedByChip(task.acceptedBy!, accentColor, mutedColor, highlighted),
                      ],
                      const Spacer(),
                      _actionWidget(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Action widget ───────────────────────────────────────

  Widget _actionWidget() {
    if (task.status == TaskStatus.todo && onAccept != null) {
      return _actionButton('Accept', kPrimary, Colors.white, onAccept!);
    }
    if (task.status == TaskStatus.inProgress) {
      return _progressCountBadge();
    }
    if (task.status == TaskStatus.done) {
      return _doneBadge();
    }
    return const SizedBox.shrink();
  }

  Widget _progressCountBadge() {
    final count = task.progressItems.length;
    final color = highlighted ? Colors.white : kPrimary;
    final bg = highlighted
        ? Colors.white.withValues(alpha: 0.2)
        : kPrimary.withValues(alpha: 0.1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notes_rounded, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            '$count ${count == 1 ? 'note' : 'notes'}',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressBar(bool highlighted, bool isDark, Color textColor) {
    final done =
        task.progressItems.where((s) => s.startsWith('[x]')).length;
    final total = task.progressItems.length;
    final value = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
    final barBg = highlighted
        ? Colors.white.withValues(alpha: 0.2)
        : (isDark ? Colors.white12 : kPrimary.withValues(alpha: 0.08));
    final barFg =
        highlighted ? Colors.white.withValues(alpha: 0.85) : kPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Progress',
              style: TextStyle(fontSize: 11, color: textColor),
            ),
            const Spacer(),
            Text(
              total == 0 ? 'No notes' : '$done / $total',
              style: TextStyle(
                fontSize: 11,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: barBg,
            valueColor: AlwaysStoppedAnimation(barFg),
            minHeight: 5,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
      String label, Color bg, Color fg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _doneBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded,
              color: Color(0xFF4CAF50), size: 12),
          SizedBox(width: 4),
          Text(
            'Done',
            style: TextStyle(
              color: Color(0xFF4CAF50),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom sheet menu ───────────────────────────────────

  void _showMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              leading: Icon(
                Icons.edit_outlined,
                color: isDark ? Colors.white70 : kTextDark,
              ),
              title: Text(
                'Edit',
                style:
                    TextStyle(color: isDark ? Colors.white : kTextDark),
              ),
              onTap: () {
                Navigator.pop(context);
                onTap();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: kHighPriority,
              ),
              title: const Text(
                'Delete',
                style: TextStyle(color: kHighPriority),
              ),
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

  // ── Tag helpers ─────────────────────────────────────────

  Widget _statusTag(bool highlighted, bool isDark) {
    if (highlighted) return const SizedBox.shrink();
    final color = task.statusColor;
    return _pill(
      task.statusLabel,
      color.withValues(alpha: 0.12),
      color,
    );
  }

  Widget _categoryTag(bool highlighted, bool isDark) {
    if (highlighted) {
      return _pill(task.category, Colors.black.withOpacity(0.2), Colors.white);
    }
    return _pill(task.category, _catBg(), _catFg());
  }

  Widget _priorityTag(bool highlighted) {
    final color = highlighted ? Colors.white : task.priorityColor;
    final bg = highlighted
        ? Colors.black.withValues(alpha: 0.15)
        : task.priorityColor.withValues(alpha: 0.12);
    return _pill(task.priorityLabel, bg, color);
  }

  Widget _acceptedByChip(
      String name, Color accentColor, Color mutedColor, bool highlighted) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.person_outline_rounded, size: 11, color: mutedColor),
        const SizedBox(width: 3),
        Text(
          name,
          style: TextStyle(
            fontSize: 11,
            color: mutedColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _catBg() {
    switch (task.category) {
      case 'Meeting':
        return const Color(0xFFE3F2FD);
      case 'Engineering':
        return const Color(0xFFEDE7F6);
      case 'Design':
        return const Color(0xFFFCE4EC);
      case 'Research':
        return const Color(0xFFE0F7FA);
      case 'Documentation':
        return const Color(0xFFFFF8E1);
      case 'Marketing':
        return const Color(0xFFF3E5F5);
      case 'Maintenance':
        return const Color(0xFFECEFF1);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  Color _catFg() {
    switch (task.category) {
      case 'Meeting':
        return const Color(0xFF1976D2);
      case 'Engineering':
        return const Color(0xFF6B3FA0);
      case 'Design':
        return const Color(0xFFD81B60);
      case 'Research':
        return const Color(0xFF00838F);
      case 'Documentation':
        return const Color(0xFFF57C00);
      case 'Marketing':
        return const Color(0xFF8E24AA);
      case 'Maintenance':
        return const Color(0xFF546E7A);
      default:
        return kTextMuted;
    }
  }

  Widget _pill(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${m[date.month - 1]} ${date.year}';
  }
}
