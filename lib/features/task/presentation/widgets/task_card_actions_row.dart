import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/confirm_delete_dialog_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/show_task_dialog.dart';

class TaskCardActionsRow extends StatelessWidget {
  const TaskCardActionsRow({
    super.key,
    required this.task,
    required this.isDark,
    required this.ctrl,
    required this.canEdit,
  });

  final TaskItem task;
  final bool isDark;
  final TaskController ctrl;

  /// True only when the current user is the task creator.
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final menuBg = isDark ? const Color(0xFF24243A) : Colors.white;
    if (!canEdit) return const SizedBox.shrink();

    return PopupMenuButton<_TaskCardAction>(
      tooltip: 'Task actions',
      color: menuBg,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      offset: const Offset(0, 10),
      onSelected: (action) async {
        switch (action) {
          case _TaskCardAction.edit:
            showTaskDialog(context, isDark, task: task);
            break;
          case _TaskCardAction.delete:
            final ok = await showConfirmDeleteDialog(
              context,
              title: 'Delete Task',
              message:
                  'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
            );
            if (ok == true) ctrl.deleteTask(task);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<_TaskCardAction>(
          value: _TaskCardAction.edit,
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, size: 18, color: kPrimary),
              const SizedBox(width: 10),
              Text(
                'Edit',
                style: TextStyle(
                  color: isDark ? Colors.white : kTextDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<_TaskCardAction>(
          value: _TaskCardAction.delete,
          child: Row(
            children: [
              const Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: kHighPriority,
              ),
              const SizedBox(width: 10),
              Text(
                'Delete',
                style: TextStyle(
                  color: isDark ? Colors.white : kTextDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
      icon: Icon(
        Icons.more_vert_rounded,
        color: isDark ? Colors.white54 : kTextMuted,
        size: 20,
      ),
    );
  }
}

enum _TaskCardAction { edit, delete }
