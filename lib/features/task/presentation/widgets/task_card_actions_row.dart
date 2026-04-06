import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/confirm_delete_dialog_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/show_task_detail_sheet.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/show_task_dialog.dart';

class TaskCardActionsRow extends StatelessWidget {
  const TaskCardActionsRow({
    super.key,
    required this.task,
    required this.isDark,
    required this.ctrl,
    required this.fetchDetail,
    required this.canEdit,
  });

  final TaskItem task;
  final bool isDark;
  final TaskController ctrl;
  final Future<TaskItem?> Function(String id)? fetchDetail;

  /// True only when the current user is the task creator.
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.06);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 1, thickness: 1, color: dividerColor),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
          child: Row(
            children: [
              // ── View detail ──
              _ActionButton(
                icon: Icons.open_in_new_rounded,
                label: 'View',
                color: isDark ? Colors.white60 : kTextMuted,
                onTap: () => showTaskDetailSheet(
                  context,
                  isDark,
                  task,
                  fetchDetail: fetchDetail,
                ),
              ),
              const Spacer(),
              if (canEdit) ...[
                // ── Edit ──
                _ActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  color: kPrimary,
                  onTap: () => showTaskDialog(context, isDark, task: task),
                ),
                const SizedBox(width: 8),
                // ── Delete ──
                _ActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
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
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
