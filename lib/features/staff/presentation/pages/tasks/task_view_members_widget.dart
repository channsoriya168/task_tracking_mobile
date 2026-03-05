import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'task_view_widgets.dart';

/// Only render this widget when [members] is non-empty.
/// The page is responsible for the conditional check.
class TaskViewMembersSection extends StatelessWidget {
  const TaskViewMembersSection({
    super.key,
    required this.members,
    required this.isDark,
    required this.borderColor,
    required this.cardBg,
  });

  final List<String> members;
  final bool isDark;
  final Color borderColor;
  final Color cardBg;

  static const _avatarColors = [
    Color(0xFF6C63FF),
    Color(0xFF1976D2),
    Color(0xFF00838F),
    Color(0xFF6B3FA0),
    Color(0xFFD81B60),
    Color(0xFFF57C00),
  ];

  @override
  Widget build(BuildContext context) {
    return TaskViewSectionCard(
      borderColor: borderColor,
      cardBg: cardBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TaskViewSectionHeader(label: 'Team Members', isDark: isDark),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${members.length} member${members.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: kPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: members.asMap().entries.map((e) {
              final color = _avatarColors[e.key % _avatarColors.length];
              final initials = e.value
                  .trim()
                  .split(' ')
                  .where((s) => s.isNotEmpty)
                  .map((s) => s[0].toUpperCase())
                  .take(2)
                  .join();
              return _MemberChip(
                name: e.value,
                initials: initials,
                color: color,
                isDark: isDark,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Member chip ───────────────────────────────────────────────────

class _MemberChip extends StatelessWidget {
  const _MemberChip({
    required this.name,
    required this.initials,
    required this.color,
    required this.isDark,
  });

  final String name;
  final String initials;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.20 : 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}
