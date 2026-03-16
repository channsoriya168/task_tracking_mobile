import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task_chart_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/week_calendar_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/manager_dashboard_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/dashboard/dashboard_date_header_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/dashboard/dashboard_task_count_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/manager_task_card_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/manager_task_filter_bar_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/task_empty_state.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/dashboard/task_card_shimmer_widget.dart';

class ManagerDashboardPage extends StatelessWidget {
  const ManagerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ManagerDashboardController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : kTextDark;
    final mutedColor = isDark ? Colors.white38 : kTextMuted;
    final cardBg = isDark ? kCardDark : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: Obx(() {
        final grouped = ctrl.groupedTasks;
        final totalCount = ctrl.filteredTasks.length;

        // Flatten into a mixed list: String = date header, TaskItem = card
        final items = <Object>[];
        for (final entry in grouped.entries) {
          items.add(entry.key);
          items.addAll(entry.value);
        }

        return CustomScrollView(
          slivers: [
            // ── App Bar ───────────────────────────────────────
            SliverAppBar(
              backgroundColor: isDark ? kBgDark : kBgLight,
              pinned: true,
              title: Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark ? kCardDark : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.10)
                              : Colors.black.withValues(alpha: 0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.25 : 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        size: 22,
                        color: isDark ? Colors.white : kTextDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Week Calendar ─────────────────────────────────
            SliverPadding(
              padding: kPageSectionPadding,
              sliver: SliverToBoxAdapter(
                child: WeekCalendarWidget(
                  isDark: isDark,
                  selectedDate: ctrl.selectedDate.value,
                  onDateSelected: ctrl.selectDate,
                ),
              ),
            ),

            // ── Doughnut Chart ────────────────────────────────
            SliverPadding(
              padding: kPageSectionLargePadding,
              sliver: SliverToBoxAdapter(
                child: TaskChartWidget(
                  isDark: isDark,
                  tasks: ctrl.tasks,
                  taskStatus: ctrl.taskStatus,
                ),
              ),
            ),

            // ── Filter Bar ────────────────────────────────────
            SliverToBoxAdapter(
              child: ManagerTaskFilterBarWidget(
                isDark: isDark,
                filterStatus: ctrl.filterStatus,
                taskStatus: ctrl.taskStatus,
                allTasks: ctrl.allTasks,
                onSelectStatus: ctrl.selectStatus,
              ),
            ),

            // ── Search Bar ────────────────────────────────────
            SliverPadding(
              padding: kPageSectionPadding,
              sliver: SliverToBoxAdapter(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: TextField(
                    onChanged: (v) => ctrl.searchQuery.value = v,
                    style: TextStyle(fontSize: 14, color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Search tasks…',
                      hintStyle: TextStyle(fontSize: 14, color: mutedColor),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: mutedColor,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Task count ────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: DashboardTaskCountWidget(
                  count: totalCount,
                  isDark: isDark,
                  hasDateFilter: ctrl.dashboardDateFilter.value != null,
                  onClearDate: () => ctrl.dashboardDateFilter.value = null,
                ),
              ),
            ),

            // ── Grouped Task List ─────────────────────────────
            if (ctrl.isLoading.value)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TaskCardShimmerWidget(isDark: isDark),
                    ),
                    childCount: 5,
                  ),
                ),
              )
            else if (items.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: TaskEmptyState(isDark: isDark),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final item = items[i];
                    if (item is String) {
                      return DashboardDateHeaderWidget(
                        label: item,
                        isDark: isDark,
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ManagerTaskCardWidget(
                        task: item as TaskItem,
                        fetchDetail: ctrl.fetchTaskById,
                      ),
                    );
                  }, childCount: items.length),
                ),
              ),
          ],
        );
      }),
    );
  }
}
