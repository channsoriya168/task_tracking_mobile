import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/format_date.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/confirm_delete_dialog_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/show_task_detail_sheet.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_card_actions_row.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_card_date_row.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_card_footer_row.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_card_title_row.dart';

class TaskCardWidget extends StatelessWidget {
  const TaskCardWidget({
    super.key,
    required this.task,
    this.managerTaskController,
    this.fetchDetail,
  });

  final TaskItem task;

  /// When null the card is read-only (no action bar shown).
  final TaskController? managerTaskController;

  /// When provided, the detail sheet fetches fresh data from the API on open.
  final Future<TaskItem?> Function(String id)? fetchDetail;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? kCardDark : Colors.white;
    final mutedColor = isDark ? Colors.white54 : kTextMuted;
    final ctrl = managerTaskController;

    // Only the task creator can edit or delete
    String? currentEmployeeId;
    try {
      currentEmployeeId = Get.find<AuthController>().profile.value?.employeeId;
    } catch (_) {}
    final isOwner =
        currentEmployeeId != null &&
        task.createdById != null &&
        currentEmployeeId == task.createdById;

    final statusColor = task.status.color;
    final priorityColor = task.priority.color;

    final startLabel = task.startDate != null
        ? formatDate(task.startDate!)
        : (task.createdAt != null ? formatDate(task.createdAt!) : '');

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
                // ── Left accent strip ──
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Main info ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TaskCardTitleRow(
                              task: task,
                              isDark: isDark,
                              mutedColor: mutedColor,
                            ),
                            const SizedBox(height: 8),
                            TaskCardDateRow(
                              mutedColor: mutedColor,
                              startLabel: startLabel,
                              isStartFallback: task.startDate == null,
                              dueDate: task.dueDate,
                            ),
                            const SizedBox(height: 8),
                            TaskCardFooterRow(
                              task: task,
                              isDark: isDark,
                              mutedColor: mutedColor,
                              statusColor: statusColor,
                              priorityColor: priorityColor,
                            ),
                          ],
                        ),
                      ),
                      // ── Action bar (manager only) ──
                      if (ctrl != null)
                        TaskCardActionsRow(
                          task: task,
                          isDark: isDark,
                          ctrl: ctrl,
                          fetchDetail: fetchDetail,
                          canEdit: isOwner,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ctrl == null) return cardContent;

    // Swipe-to-delete only available to the task creator
    if (!isOwner) return cardContent;

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
