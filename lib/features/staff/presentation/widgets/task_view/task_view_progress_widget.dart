import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/staff/presentation/widgets/task_view/task_view_widgets.dart';

class TaskViewProgressSection extends StatelessWidget {
  const TaskViewProgressSection({
    super.key,
    required this.items,
    required this.isDark,
    required this.borderColor,
    required this.cardBg,
  });

  final List<String> items;
  final bool isDark;
  final Color borderColor;
  final Color cardBg;

  static String _itemText(String item) =>
      item.startsWith('[x]') ? item.substring(3).trim() : item.trim();

  @override
  Widget build(BuildContext context) {
    return TaskViewSectionCard(
      borderColor: borderColor,
      cardBg: cardBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with optional count badge
          Row(
            children: [
              TaskViewSectionHeader(label: 'Progress Notes', isDark: isDark),
              if (items.isNotEmpty) ...[
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: kLowPriority.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${items.length} note${items.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: kLowPriority,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Empty state
          if (items.isEmpty) ...[
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.notes_rounded,
                    size: 38,
                    color: isDark
                        ? Colors.white12
                        : const Color(0xFFD1D5DB),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No progress notes recorded',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white30
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Progress notes are added while a task\nis in progress.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: isDark ? Colors.white24 : kTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ] else ...[
            const SizedBox(height: 12),
            ...items.map((item) => _ProgressNoteItem(
                  text: _itemText(item),
                  isDark: isDark,
                  borderColor: borderColor,
                )),
          ],
        ],
      ),
    );
  }
}

// ── Individual progress note ──────────────────────────────────────

class _ProgressNoteItem extends StatelessWidget {
  const _ProgressNoteItem({
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
            width: 6,
            height: 6,
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
                color: isDark
                    ? Colors.white70
                    : const Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
