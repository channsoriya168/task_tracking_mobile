import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/staff/data/models/task_model.dart';
import 'package:task_tracking_mobile/features/staff/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/features/staff/presentation/pages/tasks/task_detail_page.dart';
import 'package:task_tracking_mobile/features/staff/presentation/pages/tasks/task_view_page.dart';
import 'package:task_tracking_mobile/features/staff/presentation/widgets/task/task_sheets.dart';
import 'package:task_tracking_mobile/features/staff/presentation/widgets/task/task_card.dart';
import 'package:task_tracking_mobile/features/staff/presentation/widgets/task/task_empty_state.dart';
import 'package:task_tracking_mobile/features/staff/presentation/widgets/task/task_filter_tab.dart';
import 'package:task_tracking_mobile/features/staff/presentation/widgets/task/task_page_header.dart';
import 'package:task_tracking_mobile/features/staff/presentation/widgets/task/task_search_bar.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TaskController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaskPageHeader(isDark: isDark),
            Padding(
              padding: kPagePadding,
              child: Row(
                children: [
                  TaskFilterTab(
                    filter: 'Todo',
                    count: ctrl.todoCount,
                    ctrl: ctrl,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  TaskFilterTab(
                    filter: 'InProgress',
                    count: ctrl.inReviewCount,
                    ctrl: ctrl,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  TaskFilterTab(
                    filter: 'Complete',
                    count: ctrl.completedTasks,
                    ctrl: ctrl,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            TaskSearchBar(ctrl: ctrl, isDark: isDark),
            Expanded(
              child: ctrl.filteredTasks.isEmpty
                  ? TaskEmptyState(isDark: isDark)
                  : ListView.builder(
                      padding: kPageBottomPadding,
                      itemCount: ctrl.filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = ctrl.filteredTasks[index];
                        final highlighted =
                            task.status == TaskStatus.inProgress && index == 0;
                        return Padding(
                          padding: kItemSpacing,
                          child: TaskCard(
                            task: task,
                            highlighted: highlighted,
                            onToggle: () => ctrl.toggleComplete(task.id),
                            onDelete: () => ctrl.deleteTask(task.id),
                            onTap: task.status == TaskStatus.done
                                ? () => Get.to(() => TaskViewPage(task: task))
                                : () {},
                            onAccept: task.status == TaskStatus.todo
                                ? () => showProgressSheet(context, ctrl, task)
                                : null,
                            onFinish: task.status == TaskStatus.inProgress
                                ? () => Get.to(
                                    () => TaskDetailPage(task: task, ctrl: ctrl),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
