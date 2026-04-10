import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/widgets/no_internet_dialog.dart';
import 'package:task_tracking_mobile/features/group/presentation/controllers/group_controller.dart';
import 'package:task_tracking_mobile/features/group/domain/entities/group.dart';
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
      _TaskSheetBody(isDark: isDark, ctrl: ctrl, groups: groups),
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

// ── Offline-aware wrapper for the create/edit task sheet ──────────────────────

class _TaskSheetBody extends StatefulWidget {
  final bool isDark;
  final TaskController ctrl;
  final List<Group> groups;

  const _TaskSheetBody({
    required this.isDark,
    required this.ctrl,
    required this.groups,
  });

  @override
  State<_TaskSheetBody> createState() => _TaskSheetBodyState();
}

class _TaskSheetBodyState extends State<_TaskSheetBody> {
  late final Worker _worker;

  @override
  void initState() {
    super.initState();
    _worker = ever(Get.find<NetworkController>().isConnected, (bool connected) {
      if (!connected) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _handleOffline());
      }
    });
  }

  void _handleOffline() {
    if (!mounted) return;
    Get.back(); // close the bottom sheet
    showNoInternetDialog(isDark: widget.isDark, redirectCount: 1);
  }

  @override
  void dispose() {
    _worker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TaskItemDialogSheetWidget(
      isDark: widget.isDark,
      ctrl: widget.ctrl,
      groups: widget.groups,
    );
  }
}
