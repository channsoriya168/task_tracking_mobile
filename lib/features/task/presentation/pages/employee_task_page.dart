import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
import 'package:task_tracking_mobile/core/widgets/week_calendar_widget.dart';
import 'package:task_tracking_mobile/core/widgets/search_bar_widget.dart';
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
      appBar: AppBar(
        title: Text(
          'nav_tasks'.tr,
          style: AppTextStyles.appBarTitle(color: kPrimary),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
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
              //appbar SliverToBoxAdapter(
              SliverAppBar(
                pinned: true,
                backgroundColor: isDark ? kBgDark : kBgLight,
                elevation: 0,
                //Week calendar and Status filter bar
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(132),
                  child: Column(
                    children: [
                      // ── Week calendar ──────────────────────────────────
                      Padding(
                        padding: kPagePaddingHorizontal,
                        child: Obx(
                          () => WeekCalendarWidget(
                            isDark: isDark,
                            selectedDate: ctrl.taskSelectedDate.value,
                            onDateSelected: ctrl.selectTaskDate,
                          ),
                        ),
                      ),

                      // ── Status filter bar ──────────────────────────────
                      EmployeeTaskFilterBarWidget(
                        isDark: isDark,
                        filterStatus: ctrl.filterStatus,
                        taskStatus: ctrl.taskStatus,
                        allTasks: ctrl.myTasks,
                        onSelectStatus: ctrl.selectStatus,
                      ),
                    ],
                  ),
                ),
              ),
              // ── Search bar ─────────────────────────────────────
              SliverToBoxAdapter(
                child: SearchBarWidget(
                  hintText: 'search_tasks'.tr,
                  isDark: isDark,
                  onChanged: (v) => ctrl.searchQuery.value = v,
                ),
              ),

              // ── Task list / shimmer / empty ────────────────────
              Obx(() {
                final offline =
                    !Get.find<NetworkController>().isConnected.value;
                if (ctrl.isLoading.value || (offline && ctrl.myTasks.isEmpty)) {
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
