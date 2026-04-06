import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
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
            if (ctrl.isLoading.value && ctrl.myTasks.isEmpty) {
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
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Left accent strip ──
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade400,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            // ── Content ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title + priority dot
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _ShimmerBox(
                            isDark: isDark,
                            width: double.infinity,
                            height: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _ShimmerBox(isDark: isDark, width: 10, height: 10, radius: 5),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Description line 1
                    _ShimmerBox(isDark: isDark, width: double.infinity, height: 12),
                    const SizedBox(height: 5),
                    // Description line 2 (shorter)
                    _ShimmerBox(isDark: isDark, width: 180, height: 12),
                    const SizedBox(height: 10),
                    // Due date
                    _ShimmerBox(isDark: isDark, width: 100, height: 12),
                    const SizedBox(height: 14),
                    // Bottom row: avatar + action button
                    Row(
                      children: [
                        _ShimmerBox(isDark: isDark, width: 28, height: 28, radius: 14),
                        const Spacer(),
                        _ShimmerBox(isDark: isDark, width: 90, height: 32, radius: 10),
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
    this.radius = 6,
  });

  final bool isDark;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.white24 : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
