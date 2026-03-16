import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/helper/format_date.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/confirm_delete_dialog_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/menu_sheet_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/status_badge_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/manager_task_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/show_task_dialog.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/show_task_detail_sheet.dart';

class ManagerTaskCardWidget extends StatelessWidget {
  const ManagerTaskCardWidget({
    super.key,
    required this.task,
    this.managerTaskController,
    this.fetchDetail,
  });

  final TaskItem task;

  /// When null the card is read-only (no swipe-to-delete, no edit/delete menu).
  final ManagerTaskController? managerTaskController;

  /// When provided, the detail sheet fetches fresh data from the API on open.
  final Future<TaskItem?> Function(String id)? fetchDetail;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? kCardDark : Colors.white;
    final mutedColor = isDark ? Colors.white54 : kTextMuted;
    final ctrl = managerTaskController;

    final statusColor = task.status.color;
    final priorityColor = task.priority.color;

    final cardContent = GestureDetector(
      onTap: () =>
          showTaskDetailSheet(context, isDark, task, fetchDetail: fetchDetail),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.07),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Left accent strip (status color) ──
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [statusColor, statusColor.withValues(alpha: 0.4)],
                    ),
                  ),
                ),
                // ── Content ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1 — title + menu
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                task.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : kTextDark,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ),
                            if (ctrl != null)
                              MenuSheetWidget(
                                isDark: isDark,
                                actions: [
                                  MenuSheetAction(
                                    label: 'Edit',
                                    icon: Icons.edit_outlined,
                                    onTap: () => showTaskDialog(
                                      context,
                                      isDark,
                                      task: task,
                                    ),
                                  ),
                                  MenuSheetAction(
                                    label: 'Delete',
                                    icon: Icons.delete_outline_rounded,
                                    color: kHighPriority,
                                    onTap: () async {
                                      final ok = await showConfirmDeleteDialog(
                                        context,
                                        title: 'Delete Task',
                                        message:
                                            'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
                                      );
                                      if (ok == true) ctrl.deleteTask(task);
                                    },
                                  ),
                                ],
                              ),
                          ],
                        ),
                        // Row 2 — description
                        if ((task.description ?? '').isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            task.description ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: mutedColor,
                              height: 1.4,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        // Row 3 — start date → due date
                        Row(
                          children: [
                            Icon(
                              Icons.today_rounded,
                              size: 11,
                              color: mutedColor,
                            ),
                            const SizedBox(width: 4),
                            if (task.startDate != null)
                              Text(
                                formatDate(task.startDate!),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: mutedColor,
                                ),
                              ),
                            if (task.startDate == null)
                              Text(
                                formatDate(task.createdAt!),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: mutedColor,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            if (task.dueDate != null) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: Icon(
                                  Icons.arrow_right_alt_rounded,
                                  size: 13,
                                  color: mutedColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formatDate(task.dueDate!),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Row 4 — status badge · priority dot · label · assignee
                        Row(
                          children: [
                            StatusBadgeWidget(
                              label: task.status.name,
                              color: statusColor,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: priorityColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.priority.name,
                              style: TextStyle(
                                fontSize: 11,
                                color: mutedColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if ((task.labelName ?? task.groupName) != null)
                              _NeutralChip(
                                label: task.labelName ?? task.groupName!,
                                isDark: isDark,
                              ),
                            const Spacer(),
                            if (task.assignedToName != null)
                              _SingleAvatar(name: task.assignedToName!),
                            if (task.createdByEmployeeName != null)
                              _SingleAvatar(
                                name: task.createdByEmployeeName!,
                                color: mutedColor,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ctrl == null) return cardContent;

    return Dismissible(
      key: Key(task.id),
      confirmDismiss: (_) => showConfirmDeleteDialog(
        context,
        title: 'Delete Task',
        message:
            'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
      ),
      onDismissed: (_) => ctrl.deleteTask(task),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: kHighPriority.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kHighPriority.withValues(alpha: 0.2)),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: kHighPriority,
          size: 22,
        ),
      ),
      child: cardContent,
    );
  }
}

// ── Neutral chip ───────────────────────────────────────────────
class _NeutralChip extends StatelessWidget {
  const _NeutralChip({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);
    final fg = isDark ? Colors.white60 : kTextMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: fg),
      ),
    );
  }
}

// ── Single avatar ──────────────────────────────────────────────
class _SingleAvatar extends StatelessWidget {
  const _SingleAvatar({required this.name, this.color});
  final String name;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? kPrimary;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: c),
      ),
    );
  }
}
