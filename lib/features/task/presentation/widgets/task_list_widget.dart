import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_card_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_shimmer_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/task_empty_state.dart';

class TaskListWidget extends StatelessWidget {
  const TaskListWidget({
    super.key,
    required this.isDark,
    required this.taskController,
  });

  final bool isDark;
  final TaskController taskController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (taskController.isLoading.value) {
        return ManagerTaskListShimmer(isDark: isDark);
      }

      final tasks = taskController.filteredTasks;
      if (tasks.isEmpty) return TaskEmptyState(isDark: isDark);

      return ListView.builder(
        padding: kPageBottomPadding,
        itemCount: tasks.length,
        itemBuilder: (_, i) {
          final task = tasks[i];
          return Padding(
            padding: kItemSpacing,
            child: TaskCardWidget(
              task: task,
              managerTaskController: taskController,
            ),
          );
        },
      );
    });
  }
}
