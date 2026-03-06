// ── Manager Task Card ──────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/data/models/task_model.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/confirm_delete_dialog_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/menu_sheet_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/manager_task_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/task_dialog_wiget.dart';

class ManagerTaskCardWidget extends StatelessWidget {
  const ManagerTaskCardWidget({
    super.key,
    required this.task,
    required this.managerTaskController,
  });

  final TaskModel task;
  final ManagerTaskController managerTaskController;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? kCardDark : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : const Color(0xFFD1D5DB);
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final mutedColor = isDark ? Colors.white38 : const Color(0xFF9CA3AF);
    final isOverdue = task.isOverdue;
    final positionColor = managerTaskController.positionColor(task.category);

    final done = task.progressItems.where((s) => s.startsWith('[x]')).length;
    final total = task.progressItems.length;
    final progressValue = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);

    return Dismissible(
      key: Key(task.id),
      direction: task.status == TaskStatus.done
          ? DismissDirection.none
          : DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showConfirmDeleteDialog(
          context,
          title: 'Delete Task',
          message:
              'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
        );
      },
      onDismissed: (_) => managerTaskController.deleteTask(task.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: kHighPriority.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kHighPriority.withValues(alpha: 0.2)),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: kHighPriority,
          size: 20,
        ),
      ),
      child: GestureDetector(
        onTap: () => showTaskDetailSheet(
          context,
          isDark,
          task,
          managerTaskController,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          MenuSheetWidget(
                            isDark: isDark,
                            mutedColor: mutedColor,
                            actions: [
                              MenuSheetAction(
                                label: 'Edit',
                                icon: Icons.edit_outlined,
                                onTap: () {
                                  showTaskDialog(context, isDark, task: task);
                                },
                              ),
                              MenuSheetAction(
                                label: 'Delete',
                                icon: Icons.delete_outline_rounded,
                                color: kHighPriority,
                                onTap: () async {
                                  final confirmed = await showConfirmDeleteDialog(
                                    context,
                                    title: 'Delete Task',
                                    message:
                                        'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
                                  );
                                  if (confirmed == true) {
                                    managerTaskController.deleteTask(task.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Title
                      Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                          height: 1.4,
                        ),
                      ),
                      // Description
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: mutedColor,
                            height: 1.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      // Position badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: positionColor
                                  .withValues(alpha: isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: positionColor
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.work_outline_rounded,
                                  size: 10,
                                  color: positionColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  task.category,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: positionColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.10)
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            isOverdue
                                ? Icons.error_outline_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 13,
                            color: isOverdue ? kHighPriority : task.statusColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _footerLabel(isOverdue),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isOverdue ? kHighPriority : mutedColor,
                            ),
                          ),
                          const Spacer(),
                          // Who accepted
                          if (task.acceptedBy != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: kPrimary.withValues(
                                      alpha: isDark ? 0.25 : 0.12,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: kPrimary.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    task.acceptedBy![0].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: kPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  task.acceptedBy!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: mutedColor,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (task.status == TaskStatus.inProgress)
                  SizedBox(
                    height: 3,
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: isDark
                          ? Colors.white12
                          : kPrimary.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation(
                        progressValue >= 1.0 ? kLowPriority : kPrimary,
                      ),
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _footerLabel(bool isOverdue) {
    final statusPart = task.statusLabel;
    if (task.dueDate == null) return statusPart;
    const m = [
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
    final d = task.dueDate!;
    final datePart = '${d.day} ${m[d.month - 1]}';
    return isOverdue ? 'Overdue · $datePart' : '$statusPart · $datePart';
  }
}
