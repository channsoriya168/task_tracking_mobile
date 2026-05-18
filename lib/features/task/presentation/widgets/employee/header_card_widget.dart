import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
import 'package:task_tracking_mobile/core/widgets/status_badge_widget.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/priority_badge_widget.dart';

class HeaderCardWidget extends StatelessWidget {
  const HeaderCardWidget({super.key, required this.isDark, required this.task});
  final bool isDark;
  final TaskItem task;
  Color get textColor => isDark ? Colors.white : kTextDark;
  Color get mutedColor => isDark ? Colors.white38 : kTextMuted;
  Color get surfaceColor => isDark
      ? Colors.white.withValues(alpha: 0.05)
      : Colors.black.withValues(alpha: 0.03);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 0, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Status + priority badges ──
                Row(
                  children: [
                    StatusBadgeWidget(
                      label: task.status.localizedName,
                      color: task.status.color,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    PriorityBadgeWidget(task: task, isDark: isDark),
                  ],
                ),
                const SizedBox(height: 10),
                // ── Title ──
                Text(
                  task.title,
                  style: AppTextStyles.title(
                    color: textColor,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                // ── Description ──
                if ((task.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      task.description!,
                      style: AppTextStyles.subTitle(
                        color: mutedColor,
                      ).copyWith(height: 1.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
