import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/circular_icon_button.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task_chart_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/week_calendar_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/manager_task_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/manager_task_card_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/manager_task_filter_bar_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/task_empty_state.dart';

class ManagerDashboardPage extends StatelessWidget {
  const ManagerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final ctrl = Get.find<ManagerTaskController>();
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
        final filtered = ctrl.filteredTasks;

        return CustomScrollView(
          slivers: [
            // ── App Bar ───────────────────────────────────────
            SliverAppBar(
              backgroundColor: isDark ? kBgDark : kBgLight,
              floating: true,
              title: Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              actions: [
                Obx(
                  () => CircularIconButton(
                    icon: themeCtrl.isDark
                        ? Icons.wb_sunny_rounded
                        : Icons.nightlight_round,
                    isDark: isDark,
                    onTap: themeCtrl.toggle,
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
                  selectedDate: ctrl.taskSelectedDate.value,
                  onDateSelected: ctrl.selectTaskDate,
                ),
              ),
            ),

            // ── Doughnut Chart ────────────────────────────────
            SliverPadding(
              padding: kPageSectionLargePadding,
              sliver: SliverToBoxAdapter(
                child: TaskChartWidget(isDark: isDark, tasks: ctrl.tasks),
              ),
            ),
            SliverToBoxAdapter(
              child: ManagerTaskFilterBarWidget(isDark: isDark, ctrl: ctrl),
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

            // ── Task count + clear date ────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text(
                      'Tasks',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    if (ctrl.dashboardSelectedDate.value != null) ...[
                      const Spacer(),
                      GestureDetector(
                        onTap: () => ctrl.dashboardSelectedDate.value = null,
                        child: Row(
                          children: [
                            Icon(
                              Icons.close_rounded,
                              size: 13,
                              color: mutedColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Clear date',
                              style: TextStyle(fontSize: 12, color: mutedColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // ── Task List ─────────────────────────────────────
            filtered.isEmpty
                ? SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: TaskEmptyState(isDark: isDark),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ManagerTaskCardWidget(
                            task: filtered[i],
                            managerTaskController: ctrl,
                          ),
                        ),
                        childCount: filtered.length,
                      ),
                    ),
                  ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        );
      }),
    );
  }
}
