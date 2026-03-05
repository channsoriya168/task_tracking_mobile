import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/dashboard/dashboard_activity_card.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/dashboard/dashboard_summary_card.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/task_line_chart_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/circular_icon_button.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/staff/presentation/controllers/task_controller.dart';

class AdminDashboardMobilePage extends StatelessWidget {
  const AdminDashboardMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final taskCtrl = Get.find<TaskController>();
    final empCtrl = Get.find<EmployeeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ColoredBox(
      color: isDark ? kBgDark : kBgLight,
      child: CustomScrollView(
        slivers: [
            // ── Greeting ──────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Dashboard',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : kTextDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Overview of your team and tasks',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[500] : kTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
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
            ),
          ),

          // ── Chart ─────────────────────────────────────────
          SliverPadding(
            padding: kPagePadding,
            sliver: SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? kCardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 60 : 15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: kContentPadding,
                child: TaskLineChartWidget(isDark: isDark),
              ),
            ),
          ),

          // ── Summary Grid (2 columns) ───────────────────────
          SliverPadding(
            padding: kPageSectionLargePadding,
            sliver: Obx(() {
              final stats = buildDashboardStats(
                taskCtrl.totalTasks,
                empCtrl.employees.length,
                taskCtrl.inProgressTasks,
                taskCtrl.completedTasks,
              );
              return SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => DashboardSummaryCard(
                    isDark: isDark,
                    label: stats[i].$1,
                    count: stats[i].$2,
                    icon: stats[i].$3,
                    color: stats[i].$4,
                  ),
                  childCount: stats.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.6,
                ),
              );
            }),
          ),

          // ── Recent Activity Header ────────────────────────
          SliverPadding(
            padding: kPageSectionLargePadding,
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 13,
                      color: kPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Activity List ─────────────────────────────────
          SliverPadding(
            padding: kPageSectionPadding,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: kItemSpacing,
                  child: DashboardActivityCard(isDark: isDark, index: i),
                ),
                childCount: kDashboardActivity.length,
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
}
