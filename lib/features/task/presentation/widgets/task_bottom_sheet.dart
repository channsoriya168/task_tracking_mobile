import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/task/domain/repositories/task_item_repository.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_detail_sheet_widget.dart';

class TaskBottomSheet {
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
