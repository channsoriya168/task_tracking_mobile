part of '../../pages/tasks/task_detail_page.dart';

// ── Header card ─────────────────────────────────────────────────

class _TaskHeaderCard extends StatelessWidget {
  const _TaskHeaderCard({
    required this.task,
    required this.isDark,
    required this.borderColor,
    required this.cardBg,
  });
  final TaskModel task;
  final bool isDark;
  final Color borderColor;
  final Color cardBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                task.category.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: _categoryColor(task.category),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 4, height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : const Color(0xFFD1D5DB),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                    color: task.priorityColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text(
                task.priorityLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: task.priorityColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            task.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111827),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatusBadge(task: task),
              if (task.dueDate != null) ...[
                const SizedBox(width: 10),
                _DueDateLabel(task: task, isDark: isDark),
              ],
            ],
          ),
        ],
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
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.task});
  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: task.statusColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: task.statusColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
                color: task.statusColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            task.statusLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: task.statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _DueDateLabel extends StatelessWidget {
  const _DueDateLabel({required this.task, required this.isDark});
  final TaskModel task;
  final bool isDark;

  static String _fmt(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final color = task.isOverdue
        ? kHighPriority
        : (isDark ? Colors.white38 : kTextMuted);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          task.isOverdue
              ? Icons.warning_amber_rounded
              : Icons.calendar_today_outlined,
          size: 13,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          _fmt(task.dueDate!),
          style: TextStyle(
            fontSize: 12,
            fontWeight: task.isOverdue ? FontWeight.w600 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
