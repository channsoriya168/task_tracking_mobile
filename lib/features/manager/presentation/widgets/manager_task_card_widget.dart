// ── Manager Task Card ──────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/confirm_delete_dialog_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/menu_sheet_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/status_badge_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/manager_task_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/task_dialog_wiget.dart';

class ManagerTaskCardWidget extends StatelessWidget {
  const ManagerTaskCardWidget({
    super.key,
    required this.task,
    required this.managerTaskController,
  });

  final TaskItem task;
  final ManagerTaskController managerTaskController;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _fmt(DateTime dt) => '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? kCardDark : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFE5E7EB);
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final mutedColor = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : const Color(0xFF9CA3AF);
    final isOverdue = task.isOverdue;
    final statusColor = isOverdue ? kHighPriority : task.statusColor;

    return Dismissible(
      key: Key(task.id),
      direction: (task.status.name.toLowerCase() == 'complete' ||
              task.status.name.toLowerCase() == 'done')
          ? DismissDirection.none
          : DismissDirection.endToStart,
      confirmDismiss: (_) => showConfirmDeleteDialog(
        context,
        title: 'Delete Task',
        message:
            'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
      ),
      onDismissed: (_) => managerTaskController.deleteTask(task),
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
      child: GestureDetector(
        onTap: () =>
            showTaskDetailSheet(context, isDark, task, managerTaskController),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Left accent strip ──
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          statusColor,
                          statusColor.withValues(alpha: 0.4),
                        ],
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
                                    color: titleColor,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ),
                              MenuSheetWidget(
                                isDark: isDark,
                                mutedColor: mutedColor,
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
                                      if (ok == true) {
                                        managerTaskController.deleteTask(
                                          task,
                                        );
                                      }
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
                          // Row 3 — dates inline
                          Row(
                            children: [
                              Icon(
                                Icons.today_rounded,
                                size: 11,
                                color: mutedColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _fmt(task.createdAt ?? DateTime.now()),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: mutedColor,
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
                                Icon(
                                  isOverdue
                                      ? Icons.warning_amber_rounded
                                      : Icons.event_rounded,
                                  size: 11,
                                  color: isOverdue
                                      ? kHighPriority
                                      : kPrimary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _fmt(task.dueDate!),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isOverdue
                                        ? kHighPriority
                                        : kPrimary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Row 4 — status · category · assignee
                          Row(
                            children: [
                              // Status pill
                              StatusBadgeWidget(
                                label: isOverdue
                                    ? 'Overdue'
                                    : task.statusLabel,
                                color: statusColor,
                                isDark: isDark,
                              ),
                              const SizedBox(width: 8),
                              // Category
                              StatusBadgeWidget(
                                label: task.groupName ?? task.labelName ?? '',
                                color: statusColor,
                                isDark: isDark,
                              ),
                              const Spacer(),
                              // Assigned to
                              if (task.assignedToName != null) ...[
                                _SingleAvatar(name: task.assignedToName!),
                                const SizedBox(width: 4),
                                Text(
                                  task.assignedToName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: mutedColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
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
      ),
    );
  }
}

// ── Single avatar ─────────────────────────────────────────────
class _SingleAvatar extends StatelessWidget {
  const _SingleAvatar({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: kPrimary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: kPrimary.withValues(alpha: 0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: kPrimary,
        ),
      ),
    );
  }
}
