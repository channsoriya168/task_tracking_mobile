import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/search_bar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/week_calendar_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/employee_task_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/employee_task_card.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/employee_task_card_shimmer.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/employee_task_filter_bar_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/task_empty_state.dart';

class EmployeeTaskPage extends StatelessWidget {
  const EmployeeTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EmployeeTaskController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ctrl.fetchTasks();
            await ctrl.fetchStatuses();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Title ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: kPagePaddingHorizontal,
                  child: Text(
                    'nav_tasks'.tr,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : kTextDark,
                    ),
                  ),
                ),
              ),

              // ── Week calendar ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: kPageSectionPadding,
                  child: Obx(
                    () => WeekCalendarWidget(
                      isDark: isDark,
                      selectedDate: ctrl.taskSelectedDate.value,
                      onDateSelected: ctrl.selectTaskDate,
                    ),
                  ),
                ),
              ),

              // ── Status filter bar ──────────────────────────────
              SliverToBoxAdapter(
                child: EmployeeTaskFilterBarWidget(
                  isDark: isDark,
                  filterStatus: ctrl.filterStatus,
                  taskStatus: ctrl.taskStatus,
                  allTasks: ctrl.myTasks,
                  onSelectStatus: ctrl.selectStatus,
                ),
              ),

              // ── Search bar ─────────────────────────────────────
              SliverToBoxAdapter(
                child: SearchBarWidget(
                  isDark: isDark,
                  onChanged: (v) => ctrl.searchQuery.value = v,
                ),
              ),

              // ── Task list / shimmer / empty ────────────────────
              Obx(() {
                if (ctrl.isLoading.value && ctrl.myTasks.isEmpty) {
                  return SliverPadding(
                    padding: kPageBottomPadding,
                    sliver: SliverList.separated(
                      itemCount: 5,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, __) =>
                          EmployeeTaskCardShimmer(isDark: isDark),
                    ),
                  );
                }
                final tasks = ctrl.filteredTasks;
                if (tasks.isEmpty) {
                  return SliverPadding(
                    padding: kPageBottomPadding,
                    sliver: SliverToBoxAdapter(
                      child: SizedBox(
                        height: 280,
                        child: TaskEmptyState(isDark: isDark),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: kPageBottomPadding,
                  sliver: SliverList.separated(
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) =>
                        EmployeeTaskCard(task: tasks[i], isDark: isDark),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
