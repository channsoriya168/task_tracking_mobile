import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/circular_icon_button.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task_chart_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/week_calendar_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/manager_task_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/manager_task_card_widget.dart';

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
        // final filtered = ctrl.filteredTasks;
        final statuses = ctrl.taskPriority;

        // 'All' chip + one chip per API status
        final filters = [
          // _FilterEntry(key: 'All', label: 'All'),
          // ...statuses.map((s) => _FilterEntry(key: s.name, label: s.displayName)),
        ];

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

            // ── Doughnut Chart ────────────────────────────────
            SliverPadding(
              padding: kPageSectionLargePadding,
              sliver: SliverToBoxAdapter(
                child: TaskChartWidget(isDark: isDark, tasks: ctrl.tasks),
              ),
            ),

            // ── Week Calendar ─────────────────────────────────
            SliverPadding(
              padding: kPageSectionPadding,
              sliver: SliverToBoxAdapter(
                child: WeekCalendarWidget(
                  isDark: isDark,
                  selectedDate: ctrl.dashboardSelectedDate.value,
                  onDateSelected: (d) => ctrl.dashboardSelectedDate.value = d,
                ),
              ),
            ),

            // ── Filter Chips (from API) ───────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                  itemCount: filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final f = filters[i];
                    final selected = ctrl.filterStatus.value == f.key;
                    final color = selected
                        ? kPrimary
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : const Color(0xFF707172));
                    // final count = ctrl.countByStatus(f.key);
                    return GestureDetector(
                      onTap: () => ctrl.filterStatus.value = f.key,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? kPrimary
                              : (isDark ? kCardDark : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? kPrimary
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : const Color(0xFFE5E7EB)),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              f.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : (isDark ? Colors.grey[400] : kTextMuted),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : color.withValues(
                                        alpha: isDark ? 0.2 : 0.12,
                                      ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              // child: Text(
                              //   '$count',
                              //   style: TextStyle(
                              //     fontSize: 10,
                              //     fontWeight: FontWeight.w700,
                              //     color: selected ? Colors.white : color,
                              //   ),
                              // ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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
                      // child: Text(
                      //   '${filtered.length}',
                      //   style: const TextStyle(
                      //     fontSize: 11,
                      //     fontWeight: FontWeight.w700,
                      //     color: kPrimary,
                      //   ),
                      // ),
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
            // filtered.isEmpty
            //     ? SliverPadding(
            //         padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
            //         sliver: SliverToBoxAdapter(
            //           child: Column(
            //             children: [
            //               Icon(
            //                 Icons.inbox_rounded,
            //                 size: 48,
            //                 color: isDark ? Colors.grey[700] : Colors.grey[300],
            //               ),
            //               const SizedBox(height: 12),
            //               Text(
            //                 'No tasks found',
            //                 style: TextStyle(fontSize: 14, color: mutedColor),
            //               ),
            //             ],
            //           ),
            //         ),
            //       )
            //     : SliverPadding(
            //         padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            //         sliver: SliverList(
            //           delegate: SliverChildBuilderDelegate(
            //             (context, i) => Padding(
            //               padding: const EdgeInsets.only(bottom: 10),
            //               child: ManagerTaskCardWidget(
            //                 task: filtered[i],
            //                 managerTaskController: ctrl,
            //               ),
            //             ),
            //             childCount: filtered.length,
            //           ),
            //         ),
            //       ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        );
      }),
    );
  }
}

class _FilterEntry {
  const _FilterEntry({required this.key, required this.label});
  final String key;
  final String label;
}
