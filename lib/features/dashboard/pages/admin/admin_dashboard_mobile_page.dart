import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/dashboard/widgets/task_line_chart_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/core/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/circular_icon_button.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_card_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/week_calendar_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_filter_bar_widget.dart';

class AdminDashboardMobilePage extends StatelessWidget {
  const AdminDashboardMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final adminTaskCtrl = Get.find<TaskController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : kTextDark;
    final mutedColor = isDark ? Colors.white38 : kTextMuted;
    final cardBg = isDark ? kCardDark : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: RefreshIndicator(
        onRefresh: adminTaskCtrl.fetchTasks,
        child: Obx(() {
          final filtered = adminTaskCtrl.filteredTasks;

          return CustomScrollView(
            slivers: [
              // ── App Bar ───────────────────────────────────────
              SliverAppBar(
                backgroundColor: isDark ? kBgDark : kBgLight,
                floating: true,
                title: Text(
                  'nav_dashboard'.tr,
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
                    selectedDate: adminTaskCtrl.taskSelectedDate.value,
                    onDateSelected: adminTaskCtrl.selectTaskDate,
                  ),
                ),
              ),

              // ── Task Summary Chart (follows selected date) ────
              SliverPadding(
                padding: kPageSectionLargePadding,
                sliver: SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    child: TaskLineChartWidget(isDark: isDark),
                  ),
                ),
              ),

              // ── Filter Chips ──────────────────────────────────
              SliverToBoxAdapter(
                child: TaskFilterBarWidget(
                  isDark: isDark,
                  filterStatus: adminTaskCtrl.filterStatus,
                  taskStatus: adminTaskCtrl.taskStatus,
                  allTasks: adminTaskCtrl.allTasks,
                  onSelectStatus: adminTaskCtrl.selectStatus,
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
                      onChanged: (v) => adminTaskCtrl.searchQuery.value = v,
                      style: TextStyle(fontSize: 14, color: textColor),
                      decoration: InputDecoration(
                        hintText: 'dashboard_search_hint'.tr,
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

              // ── Task count + clear date ───────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Text(
                        'task_title'.tr,
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
                        child: Text(
                          '${filtered.length}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: kPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Task List ─────────────────────────────────────
              filtered.isEmpty
                  ? SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox_rounded,
                              size: 48,
                              color: isDark
                                  ? Colors.grey[700]
                                  : Colors.grey[300],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'task_empty'.tr,
                              style: TextStyle(fontSize: 14, color: mutedColor),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, i) {
                          final task = filtered[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TaskCardWidget(task: task),
                          );
                        }, childCount: filtered.length),
                      ),
                    ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          );
        }),
      ),
    );
  }
}
