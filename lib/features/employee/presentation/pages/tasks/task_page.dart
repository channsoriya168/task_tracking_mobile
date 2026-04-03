import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/search_bar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/week_calendar_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_task_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/employee_task_card.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/employee_task_filter_bar_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/task_empty_state.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

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
              padding: kPagePadding,
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
            if (ctrl.isLoading.value) {
              return SliverPadding(
                padding: kPageBottomPadding,
                sliver: SliverList.separated(
                  itemCount: 5,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, __) => _TaskCardShimmer(isDark: isDark),
                ),
              );
            }
            final tasks = ctrl.filteredTasks;
            if (tasks.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: TaskEmptyState(isDark: isDark),
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

// ── Shimmer skeleton that mirrors EmployeeTaskCard's shape ────────────────────

class _TaskCardShimmer extends StatelessWidget {
  const _TaskCardShimmer({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final base = isDark ? const Color(0xFF252540) : Colors.grey.shade300;
    final highlight = isDark ? const Color(0xFF3A3A60) : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.07),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // accent strip
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade400,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            // content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // title + status badge row
                    Row(
                      children: [
                        Expanded(
                          child: _ShimmerBox(
                            isDark: isDark,
                            width: double.infinity,
                            height: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _ShimmerBox(isDark: isDark, width: 60, height: 20),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // date row
                    _ShimmerBox(isDark: isDark, width: 180, height: 12),
                    const Spacer(),
                    // footer row
                    Row(
                      children: [
                        _ShimmerBox(isDark: isDark, width: 56, height: 20),
                        const SizedBox(width: 8),
                        _ShimmerBox(isDark: isDark, width: 56, height: 20),
                        const Spacer(),
                        _ShimmerBox(isDark: isDark, width: 36, height: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.isDark,
    required this.width,
    required this.height,
  });

  final bool isDark;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.white24 : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
