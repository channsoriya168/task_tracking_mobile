import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/data/models/task_model.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/manager_task_controller.dart';

enum _ChartFilter { day, week, month }

class _ChartData {
  _ChartData(this.label, this.count, this.color);
  final String label;
  final int count;
  final Color color;
}

class TaskChartWidget extends StatefulWidget {
  const TaskChartWidget({super.key, required this.isDark});
  final bool isDark;

  @override
  State<TaskChartWidget> createState() => _TaskChartWidgetState();
}

class _TaskChartWidgetState extends State<TaskChartWidget> {
  _ChartFilter _filter = _ChartFilter.day;

  List<TaskModel> _applyFilter(List<TaskModel> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return tasks.where((t) {
      final created = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
      return switch (_filter) {
        _ChartFilter.day   => created == today,
        _ChartFilter.week  => !created.isBefore(today.subtract(const Duration(days: 6))) &&
            !created.isAfter(today),
        _ChartFilter.month => !created.isBefore(today.subtract(const Duration(days: 29))) &&
            !created.isAfter(today),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final ctrl = Get.find<ManagerTaskController>();

    final cardBg = isDark ? kCardDark : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.06);
    final textColor  = isDark ? Colors.white : kTextDark;
    final mutedColor = isDark ? Colors.grey[500]! : kTextMuted;
    final chipBg     = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04);

    return Obx(() {
      final filtered   = _applyFilter(ctrl.tasks);
      final pending    = filtered.where((t) => t.status == TaskStatus.todo).length;
      final inProgress = filtered.where((t) => t.status == TaskStatus.inProgress).length;
      final done       = filtered.where((t) => t.status == TaskStatus.done).length;
      final fail       = filtered.where((t) => t.status == TaskStatus.fail).length;
      final total = pending + inProgress + done + fail;
      final data = [
        _ChartData('Pending',     pending,    kMediumPriority),
        _ChartData('In Progress', inProgress, kPrimary),
        _ChartData('Complete',    done,       kLowPriority),
        _ChartData('Fail',        fail,       kHighPriority),
      ].where((d) => d.count > 0).toList();

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
            // ── Title row with filter dropdown ──────────────
            Row(
              children: [
                Text(
                  'Task Summary',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<_ChartFilter>(
                      value: _filter,
                      isDense: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: mutedColor,
                      ),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      dropdownColor: isDark ? const Color(0xFF2A2A3A) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      items: const [
                        DropdownMenuItem(value: _ChartFilter.day,   child: Text('Day')),
                        DropdownMenuItem(value: _ChartFilter.week,  child: Text('Week')),
                        DropdownMenuItem(value: _ChartFilter.month, child: Text('Month')),
                      ],
                      onChanged: (f) { if (f != null) setState(() => _filter = f); },
                    ),
                  ),
                ),
              ],
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendItem(label: 'Pending',     count: pending,    color: kMediumPriority, total: total, isDark: isDark),
                      const SizedBox(height: 12),
                      _LegendItem(label: 'In Progress', count: inProgress, color: kPrimary,        total: total, isDark: isDark),
                      const SizedBox(height: 12),
                      _LegendItem(label: 'Complete',    count: done,       color: kLowPriority,    total: total, isDark: isDark),
                      const SizedBox(height: 12),
                      _LegendItem(label: 'Fail',        count: fail,       color: kHighPriority,   total: total, isDark: isDark),
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
