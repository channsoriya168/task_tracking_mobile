part of 'task_view_page.dart';

// ── Shared helpers ──────────────────────────────────────────────

class _ViewSectionCard extends StatelessWidget {
  const _ViewSectionCard({
    required this.child,
    required this.borderColor,
    required this.cardBg,
  });
  final Widget child;
  final Color borderColor;
  final Color cardBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class _ViewSectionHeader extends StatelessWidget {
  const _ViewSectionHeader({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: isDark ? Colors.white70 : const Color(0xFF374151),
      ),
    );
  }
}

class _ViewEmptyState extends StatelessWidget {
  const _ViewEmptyState({required this.message, required this.isDark});
  final String message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            height: 1.6,
            color: isDark ? Colors.white30 : kTextMuted,
          ),
        ),
      ),
    );
  }
}

// ── Header card ─────────────────────────────────────────────────

class _ViewHeaderCard extends StatelessWidget {
  const _ViewHeaderCard({
    required this.task,
    required this.isDark,
    required this.borderColor,
    required this.cardBg,
  });
  final TaskModel task;
  final bool isDark;
  final Color borderColor;
  final Color cardBg;

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
          // Category + priority row
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

          // Title
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

          // Status + date
          Row(
            children: [
              _ViewStatusBadge(task: task),
              if (task.dueDate != null) ...[
                const SizedBox(width: 10),
                _ViewDueDateLabel(task: task, isDark: isDark),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ViewStatusBadge extends StatelessWidget {
  const _ViewStatusBadge({required this.task});
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

class _ViewDueDateLabel extends StatelessWidget {
  const _ViewDueDateLabel({required this.task, required this.isDark});
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

// ── Description section ─────────────────────────────────────────

class _ViewDescriptionSection extends StatelessWidget {
  const _ViewDescriptionSection({
    required this.description,
    required this.isDark,
    required this.borderColor,
    required this.cardBg,
  });
  final String description;
  final bool isDark;
  final Color borderColor;
  final Color cardBg;

  @override
  Widget build(BuildContext context) {
    return _ViewSectionCard(
      borderColor: borderColor, cardBg: cardBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ViewSectionHeader(label: 'Description', isDark: isDark),
          const SizedBox(height: 10),
          description.trim().isEmpty
              ? _ViewEmptyState(
                  message: 'No description provided.',
                  isDark: isDark)
              : Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: isDark
                        ? Colors.white70
                        : const Color(0xFF374151),
                  ),
                ),
        ],
      ),
    );
  }
}

// ── Members section ─────────────────────────────────────────────

class _ViewMembersSection extends StatelessWidget {
  const _ViewMembersSection({
    required this.members,
    required this.isDark,
    required this.borderColor,
    required this.cardBg,
  });
  final List<String> members;
  final bool isDark;
  final Color borderColor;
  final Color cardBg;

  static const _colors = [
    Color(0xFF6C63FF), Color(0xFF1976D2), Color(0xFF00838F),
    Color(0xFF6B3FA0), Color(0xFFD81B60), Color(0xFFF57C00),
  ];

  @override
  Widget build(BuildContext context) {
    return _ViewSectionCard(
      borderColor: borderColor, cardBg: cardBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ViewSectionHeader(label: 'Team Members', isDark: isDark),
              if (members.isNotEmpty) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${members.length} member${members.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: kPrimary),
                  ),
                ),
              ],
            ],
          ),
          members.isEmpty
              ? _ViewEmptyState(
                  message: 'No members assigned to this task.',
                  isDark: isDark)
              : Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: members.asMap().entries.map((e) {
                      final color = _colors[e.key % _colors.length];
                      final initials = e.value.trim().split(' ')
                          .where((s) => s.isNotEmpty)
                          .map((s) => s[0].toUpperCase())
                          .take(2).join();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withValues(
                              alpha: isDark ? 0.20 : 0.10),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: color.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 22, height: 22,
                              decoration: BoxDecoration(
                                  color: color, shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: Text(initials,
                                  style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                            ),
                            const SizedBox(width: 7),
                            Text(e.value,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white70
                                        : const Color(0xFF374151))),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }
}

// ── Progress section ────────────────────────────────────────────

class _ViewProgressSection extends StatelessWidget {
  const _ViewProgressSection({
    required this.items,
    required this.isDark,
    required this.borderColor,
    required this.cardBg,
  });
  final List<String> items;
  final bool isDark;
  final Color borderColor;
  final Color cardBg;

  String _itemText(String item) =>
      item.startsWith('[x]') ? item.substring(3).trim() : item.trim();

  @override
  Widget build(BuildContext context) {
    return _ViewSectionCard(
      borderColor: borderColor, cardBg: cardBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ViewSectionHeader(label: 'Progress Notes', isDark: isDark),
              if (items.isNotEmpty) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: kLowPriority.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${items.length} note${items.length == 1 ? '' : 's'}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: kLowPriority),
                  ),
                ),
              ],
            ],
          ),
          items.isEmpty
              ? _ViewEmptyState(
                  message: 'No progress notes were recorded\nfor this task.',
                  isDark: isDark)
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    children: items
                        .map((item) => _ViewProgressNote(
                              text: _itemText(item),
                              isDark: isDark,
                              borderColor: borderColor,
                            ))
                        .toList(),
                  ),
                ),
        ],
      ),
    );
  }
}

class _ViewProgressNote extends StatelessWidget {
  const _ViewProgressNote({
    required this.text,
    required this.isDark,
    required this.borderColor,
  });
  final String text;
  final bool isDark;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6, height: 6,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: kLowPriority.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark ? Colors.white70 : const Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
