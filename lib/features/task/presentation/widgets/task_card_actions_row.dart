import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/core/widgets/no_internet_dialog.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/group/presentation/controllers/group_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_button_sheet.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/confirm_delete_dialog_widget.dart';

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
            if (!Get.find<NetworkController>().isConnected.value) {
              ctrl.isOfflineDialogOpen.value = true;
              showNoInternetDialog(
                isDark: isDark,
                redirectCount: 1,
              ).then((_) => ctrl.isOfflineDialogOpen.value = false);
              return;
            }
            final groupCtrl = Get.find<GroupController>();
            final futures = <Future<void>>[ctrl.refreshFormData()];
            if (groupCtrl.groups.isEmpty) futures.add(groupCtrl.fetchGroups());
            await Future.wait(futures);
            ctrl.openForEdit(task);
            Get.bottomSheet(
              const TaskButtonSheet(),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
            );
            break;
          case _TaskCardAction.delete:
            if (!Get.find<NetworkController>().isConnected.value) {
              ctrl.isOfflineDialogOpen.value = true;
              showNoInternetDialog(
                isDark: isDark,
                redirectCount: 1,
              ).then((_) => ctrl.isOfflineDialogOpen.value = false);
              return;
            }
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
