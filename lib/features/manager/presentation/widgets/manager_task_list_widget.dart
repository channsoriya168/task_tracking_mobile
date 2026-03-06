// ── Task List ──────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/manager_task_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/manager_task_card_widget.dart';
import 'package:task_tracking_mobile/features/staff/presentation/widgets/task/task_empty_state.dart';

class ManagerTaskList extends StatelessWidget {
  const ManagerTaskList({
    super.key,
    required this.isDark,
    required this.managerTaskController,
  });

  final bool isDark;
  final ManagerTaskController managerTaskController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tasks = managerTaskController.filteredTasks;
      if (tasks.isEmpty) return TaskEmptyState(isDark: isDark);
      return ListView.builder(
        padding: kPageBottomPadding,
        itemCount: tasks.length,
        itemBuilder: (_, i) {
          final task = tasks[i];
          return Padding(
            padding: kItemSpacing,
            child: ManagerTaskCardWidget(
              task: task,
              managerTaskController: managerTaskController,
            ),
          );
        },
      );
    });
  }
}
