import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/task_group_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_item_dialog_sheet_widget.dart';

Future<void> showTaskDialog(
  BuildContext context,
  bool isDark, {
  TaskItem? task,
}) async {
  final ctrl = Get.find<TaskController>();
  final posCtrl = Get.find<TaskGroupController>();
  final groups = posCtrl.taskGroups;

  if (task != null) {
    ctrl.openForEdit(task);
  } else {
    ctrl.resetForm(groups.toList());
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TaskItemDialogSheetWidget(
      isDark: isDark,
      ctrl: ctrl,
      groups: groups.toList(),
    ),
  );
}
