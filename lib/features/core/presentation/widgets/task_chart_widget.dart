import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item_status.dart';

class _ChartData {
  _ChartData(this.label, this.count, this.color);
  final String label;
  final int count;
  final Color color;
}

class TaskChartWidget extends StatelessWidget {
  const TaskChartWidget({
    super.key,
    required this.isDark,
    required this.tasks,
    required this.taskStatus,
  });

  final bool isDark;
  final RxList<TaskItem> tasks;
  final RxList<TaskStatusLookup> taskStatus;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? kCardDark : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.06);
    final textColor = isDark ? Colors.white : kTextDark;
    final mutedColor = isDark ? Colors.grey[500]! : kTextMuted;

    return Obx(() {
      // Count tasks per status name
      final Map<String, int> statusCounts = {};
      for (final t in tasks) {
        final name = t.status.name;
        statusCounts[name] = (statusCounts[name] ?? 0) + 1;
      }

      final total = tasks.length;

      // Build data from all statuses (show even those with 0 tasks)
      final dataWithColor = taskStatus
          .map((s) => _ChartData(s.name, statusCounts[s.name] ?? 0, s.color))
          .toList();

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
            // ── Title ────────────────────────────────────────
            Text(
              'Task Summary',
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

            // ── Doughnut + Legend ────────────────────────────
            Row(
              children: [
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
                              dataSource: dataWithColor
                                  .where((d) => d.count > 0)
                                  .toList(),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < dataWithColor.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12),
                        _LegendItem(
                          label: dataWithColor[i].label,
                          count: dataWithColor[i].count,
                          color: dataWithColor[i].color,
                          total: total,
                          isDark: isDark,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
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
