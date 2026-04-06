import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';

class TaskCardTitleRow extends StatelessWidget {
  const TaskCardTitleRow({
    super.key,
    required this.task,
    required this.isDark,
    required this.mutedColor,
  });

  final TaskItem task;
  final bool isDark;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final hasGroup = task.groupName != null;
    final hasLabel = task.labelName != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Title ───────────────────────────────────────────────
        Text(
          task.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : kTextDark,
            letterSpacing: -0.1,
            height: 1.3,
          ),
        ),

        // ── Description ──────────────────────────────────────────
        if ((task.description ?? '').isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            task.description!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: mutedColor, height: 1.4),
          ),
        ],

        // ── Group / Label pills ───────────────────────────────────
        if (hasGroup || hasLabel) ...[
          const SizedBox(height: 7),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              if (hasGroup) _MetaPill(label: task.groupName!, isDark: isDark),
              if (hasLabel) _MetaPill(label: task.labelName!, isDark: isDark),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Subtle pill chip ─────────────────────────────────────────────
class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.09)
            : Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white60 : kTextMuted,
        ),
      ),
    );
  }
}
