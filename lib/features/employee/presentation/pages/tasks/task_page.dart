import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/employee_task_card.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/filter_chip_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/search_bar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/week_calendar_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_task_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/task_empty_state.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/task_page_header.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EmployeeTaskController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TaskPageHeader(isDark: isDark),

          // ── Week calendar ──────────────────────────────────
          Padding(
            padding: kPageSectionPadding,
            child: Obx(
              () => WeekCalendarWidget(
                isDark: isDark,
                selectedDate: ctrl.taskSelectedDate.value,
                onDateSelected: ctrl.selectTaskDate,
              ),
            ),
          ),

          // ── Status filter bar ──────────────────────────────
          SizedBox(
            height: 52,
            child: Obx(() {
              final selected = ctrl.filterStatus.value;
              final statusItems = [null, ...ctrl.taskStatus];
              final counts = <String, int>{
                'All': ctrl.allTasks.length,
                for (final s in ctrl.taskStatus)
                  s.name: ctrl.allTasks
                      .where(
                        (t) =>
                            t.status.name.toLowerCase() ==
                            s.name.toLowerCase(),
                      )
                      .length,
              };
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                itemCount: statusItems.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final status = statusItems[i];
                  final label = status?.name ?? 'All';
                  return FilterChipWidget(
                    isDark: isDark,
                    filter: label,
                    count: counts[label] ?? 0,
                    selected: selected == label,
                    onTap: () => ctrl.selectStatus(status),
                  );
                },
              );
            }),
          ),

          // ── Search bar ─────────────────────────────────────
          SearchBarWidget(
            isDark: isDark,
            onChanged: (v) => ctrl.searchQuery.value = v,
          ),

          // ── Task list ──────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final tasks = ctrl.filteredTasks;
              if (tasks.isEmpty) return TaskEmptyState(isDark: isDark);
              return ListView.builder(
                padding: kPageBottomPadding,
                itemCount: tasks.length,
                itemBuilder: (_, i) {
                  final task = tasks[i];
                  return Padding(
                    padding: kItemSpacing,
                    child: EmployeeTaskCard(
                      task: task,
                      isDark: isDark,
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
