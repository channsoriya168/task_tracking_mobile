import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/group/presentation/controllers/group_controller.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/task/domain/repositories/task_item_repository.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_detail_sheet_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_item_dialog_sheet_widget.dart';

class TaskBottomSheet {
  static void showTaskSheet(bool isDark, {TaskItem? task}) {
    final ctrl = Get.find<TaskController>();
    final groupCtrl = Get.find<GroupController>();
    final groups = groupCtrl.groups.toList();
    if (task != null) {
      ctrl.openForEdit(task);
    } else {
      ctrl.resetForm(groups);
    }
    Get.bottomSheet(
      TaskItemDialogSheetWidget(isDark: isDark, ctrl: ctrl, groups: groups),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  static Future<void> showTaskDetailSheet(
    BuildContext context,
    bool isDark,
    TaskItem task, {
    Future<TaskItem?> Function(String id)? fetchDetail,
  }) async {
    TaskItemRepository? repo;
    try {
      repo = Get.find<TaskItemRepository>();
    } catch (_) {}

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskDetailSheetWidget(
        task: task,
        isDark: isDark,
        repo: repo,
        fetchDetail: fetchDetail,
      ),
    );
  }
}