import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
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
      final offline = !Get.find<NetworkController>().isConnected.value;
      final tasks = taskController.filteredTasks;

      if (taskController.isLoading.value || (offline && tasks.isEmpty)) {
        return ManagerTaskListShimmer(isDark: isDark);
      }

      if (tasks.isEmpty) return TaskEmptyState(isDark: isDark);

      return ListView.builder(
        padding: kPagePaddingHorizontal,
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
