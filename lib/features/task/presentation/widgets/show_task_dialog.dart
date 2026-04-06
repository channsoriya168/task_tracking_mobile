import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/features/group/presentation/controllers/group_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_item_dialog_sheet_widget.dart';

Future<void> showTaskDialog(
  BuildContext context,
  bool isDark, {
  TaskItem? task,
}) async {
  final ctrl = Get.find<TaskController>();
  final posCtrl = Get.find<GroupController>();
  final groups = posCtrl.groups;

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
