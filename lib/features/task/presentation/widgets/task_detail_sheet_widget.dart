import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/task/domain/repositories/task_item_repository.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/task_detail_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_detail_sheet_content_widget.dart';

class TaskDetailSheetWidget extends StatefulWidget {
  const TaskDetailSheetWidget({
    super.key,
    required this.task,
    required this.isDark,
    required this.repo,
    required this.fetchDetail,
  });

  final TaskItem task;
  final bool isDark;
  final TaskItemRepository? repo;
  final Future<TaskItem?> Function(String id)? fetchDetail;

  @override
  State<TaskDetailSheetWidget> createState() => _TaskDetailSheetWidgetState();
}

class _TaskDetailSheetWidgetState extends State<TaskDetailSheetWidget> {
  late final TaskDetailController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(
      TaskDetailController(widget.repo, widget.task),
      tag: widget.task.id,
    );
    if (widget.fetchDetail != null) _ctrl.loadFresh(widget.fetchDetail!);
  }

  @override
  void dispose() {
    Get.delete<TaskDetailController>(tag: widget.task.id, force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => TaskDetailSheetContentWidget(
        ctrl: _ctrl,
        isDark: widget.isDark,
        scrollController: scrollController,
      ),
    );
  }
}