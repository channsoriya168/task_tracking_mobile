import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/data/models/task_model.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/circular_icon_button.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/manager_task_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/manager_task_card_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/task_dialog_wiget.dart';

class ManagerDashboardMobilePage extends StatelessWidget {
  const ManagerDashboardMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final ctrl = Get.find<ManagerTaskController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTaskDialog(context, isDark),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Task',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(() {
        final tasks = ctrl.tasks;
        final total = tasks.length;
        final pending = tasks.where((t) => t.status == TaskStatus.todo).length;
        final inProgress = tasks
            .where((t) => t.status == TaskStatus.inProgress)
            .length;
        final done = tasks.where((t) => t.status == TaskStatus.done).length;
        final fail = tasks.where((t) => t.status == TaskStatus.fail).length;

        final recentTasks =
            tasks.where((t) => t.status != TaskStatus.done).toList()
              ..sort((a, b) {
                if (a.dueDate != null && b.dueDate != null)
                  return a.dueDate!.compareTo(b.dueDate!);
                if (a.dueDate != null) return -1;
                if (b.dueDate != null) return 1;
                return 0;
              });
        final preview = recentTasks.take(3).toList();

        return CustomScrollView(
          slivers: [
            // ── App Bar ─────────────────────────────────────
            SliverAppBar(
              backgroundColor: isDark ? kBgDark : kBgLight,
              floating: true,
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

            // ── Greeting ────────────────────────────────────
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

            // ── Stat Cards ──────────────────────────────────
            SliverPadding(
              padding: kPagePadding,
              sliver: SliverGrid(
                delegate: SliverChildListDelegate([
                  _StatCard(
                    isDark: isDark,
                    label: 'Total',
                    count: total,
                    icon: Icons.grid_view_rounded,
                    color: kPrimary,
                  ),
                  _StatCard(
                    isDark: isDark,
                    label: 'Pending',
                    count: pending,
                    icon: Icons.radio_button_unchecked_rounded,
                    color: kMediumPriority,
                  ),
                  _StatCard(
                    isDark: isDark,
                    label: 'In Progress',
                    count: inProgress,
                    icon: Icons.sync_rounded,
                    color: kPrimary,
                  ),
                  _StatCard(
                    isDark: isDark,
                    label: 'Complete',
                    count: done,
                    icon: Icons.check_circle_outline_rounded,
                    color: kLowPriority,
                  ),
                ]),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 76,
                ),
              ),
            ),

            // ── Doughnut Chart ──────────────────────────────
            SliverPadding(
              padding: kPageSectionLargePadding,
              sliver: SliverToBoxAdapter(
                child: _TaskChart(
                  isDark: isDark,
                  pending: pending,
                  inProgress: inProgress,
                  done: done,
                  fail: fail,
                ),
              ),
            ),

            // ── Recent Tasks Header ──────────────────────────
            SliverPadding(
              padding: kPageSectionLargePadding,
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text(
                      'Recent Tasks',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : kTextDark,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${recentTasks.length} active',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : kTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Recent Task Cards ────────────────────────────
            SliverPadding(
              padding: kPageSectionPadding,
              sliver: preview.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No active tasks',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.grey[600] : kTextMuted,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: kItemSpacing,
                          child: ManagerTaskCardWidget(
                            task: preview[i],
                            managerTaskController: ctrl,
                          ),
                        ),
                        childCount: preview.length,
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

// ── Stat Card ─────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.isDark,
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  final bool isDark;
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[500] : kTextMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Task Doughnut Chart ────────────────────────────────────────
class _ChartData {
  _ChartData(this.label, this.count, this.color);
  final String label;
  final int count;
  final Color color;
}

class _TaskChart extends StatelessWidget {
  const _TaskChart({
    required this.isDark,
    required this.pending,
    required this.inProgress,
    required this.done,
    required this.fail,
  });

  final bool isDark;
  final int pending;
  final int inProgress;
  final int done;
  final int fail;

  @override
  Widget build(BuildContext context) {
    final total = pending + inProgress + done + fail;
    final data = [
      _ChartData('Pending', pending, kMediumPriority),
      _ChartData('In Progress', inProgress, kPrimary),
      _ChartData('Complete', done, kLowPriority),
      _ChartData('Fail', fail, kHighPriority),
    ].where((d) => d.count > 0).toList();

    final cardBg = isDark ? kCardDark : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.06);
    final textColor = isDark ? Colors.white : kTextDark;
    final mutedColor = isDark ? Colors.grey[500]! : kTextMuted;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Overview',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$total tasks total',
            style: TextStyle(fontSize: 12, color: mutedColor),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Doughnut
              SizedBox(
                height: 160,
                width: 160,
                child: total == 0
                    ? Center(
                        child: Text(
                          'No data',
                          style: TextStyle(color: mutedColor, fontSize: 13),
                        ),
                      )
                    : SfCircularChart(
                        margin: EdgeInsets.zero,
                        series: [
                          DoughnutSeries<_ChartData, String>(
                            dataSource: data,
                            xValueMapper: (d, _) => d.label,
                            yValueMapper: (d, _) => d.count,
                            pointColorMapper: (d, _) => d.color,
                            innerRadius: '65%',
                            radius: '100%',
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: false,
                            ),
                          ),
                        ],
                        annotations: [
                          CircularChartAnnotation(
                            widget: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$total',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  'Tasks',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: mutedColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 20),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendItem(
                      label: 'Pending',
                      count: pending,
                      color: kMediumPriority,
                      total: total,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      label: 'In Progress',
                      count: inProgress,
                      color: kPrimary,
                      total: total,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      label: 'Complete',
                      count: done,
                      color: kLowPriority,
                      total: total,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      label: 'Fail',
                      count: fail,
                      color: kHighPriority,
                      total: total,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    required this.count,
    required this.color,
    required this.total,
    required this.isDark,
  });

  final String label;
  final int count;
  final Color color;
  final int total;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : ((count / total) * 100).round();
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : kTextDark,
            ),
          ),
        ),
        Text(
          '$count  ($pct%)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[400] : kTextMuted,
          ),
        ),
      ],
    );
  }
}
