import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/format_date.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_progress.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_detail_avatar_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_detail_empty_state_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_detail_tab_loader_widget.dart';

class TaskDetailProgressTab extends StatelessWidget {
  const TaskDetailProgressTab({
    super.key,
    required this.progresses,
    required this.loading,
    required this.isDark,
  });

  final List<TaskProgress> progresses;
  final bool loading;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (loading) return const TaskDetailTabLoader();
    if (progresses.isEmpty) {
      return TaskDetailEmptyState(
        icon: Icons.trending_flat_rounded,
        message: 'no_progress_yet',
        isDark: isDark,
      );
    }

    final divColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          for (int i = 0; i < progresses.length; i++) ...[
            if (i > 0) Divider(height: 1, color: divColor),
            TaskDetailProgressItem(progress: progresses[i], isDark: isDark),
          ],
        ],
      ),
    );
  }
}

// ── Single progress item ─────────────────────────────────────────
class TaskDetailProgressItem extends StatelessWidget {
  const TaskDetailProgressItem({
    super.key,
    required this.progress,
    required this.isDark,
  });

  final TaskProgress progress;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : kTextDark;
    final mutedColor = isDark ? Colors.white38 : kTextMuted;
    final pct = progress.progressPercentage.clamp(0, 100);
    final barColor = pct == 100
        ? const Color(0xFF2ED573)
        : pct >= 60
        ? kPrimary
        : const Color(0xFFFFA502);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TaskDetailAvatar(
                name: progress.employeeName,
                imageUrl: progress.employeeProfileImageUrl,
                size: 28,
                color: barColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  progress.employeeName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: barColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: barColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 6,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          if (progress.notes != null && progress.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              progress.notes!,
              style: TextStyle(fontSize: 12, color: mutedColor, height: 1.5),
            ),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              if (progress.loggedAt != null)
                Text(
                  formatDate(progress.loggedAt!),
                  style: TextStyle(fontSize: 10, color: mutedColor),
                ),
              if (progress.hoursWorked != null) ...[
                const SizedBox(width: 8),
                Icon(Icons.access_time_rounded, size: 10, color: mutedColor),
                const SizedBox(width: 2),
                Text(
                  '${progress.hoursWorked!.toStringAsFixed(1)}h',
                  style: TextStyle(fontSize: 10, color: mutedColor),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
