import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/dashboard/widgets/dashboard_activity_card.dart';
import 'package:task_tracking_mobile/features/dashboard/widgets/task_line_chart_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/core/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/circular_icon_button.dart';

class AdminDashboardTabletPage extends StatelessWidget {
  const AdminDashboardTabletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final taskCtrl = Get.find<TaskController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ColoredBox(
      color: isDark ? kBgDark : kBgLight,
      child: RefreshIndicator(
        onRefresh: taskCtrl.fetchTasks,
        child: CustomScrollView(
          slivers: [
            // ── App Bar ───────────────────────────────────────
            SliverAppBar(
              backgroundColor: isDark ? kBgDark : kBgLight,
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
                Padding(
                  padding: kPagePaddingHorizontal,
                  child: CircularIconButton(
                    icon: Icons.settings_outlined,
                    isDark: isDark,
                    onTap: () {},
                  ),
                ),
              ],
            ),

            // ── Greeting ──────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              sliver: SliverToBoxAdapter(
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
            // ── Recent Activity Header ────────────────────────
            SliverPadding(
              padding: kPageSectionLargePadding,
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
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

            // ── Activity Grid (3 columns) ─────────────────────
            SliverPadding(
              padding: kPageSectionPadding,
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => DashboardActivityCard(isDark: isDark, index: i),
                  childCount: kDashboardActivity.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.4,
                ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
    );
  }
}
