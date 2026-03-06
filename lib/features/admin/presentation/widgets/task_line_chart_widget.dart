import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/staff/data/models/task_model.dart';
import 'package:task_tracking_mobile/features/staff/presentation/controllers/task_controller.dart';

enum _Filter { day, week, month }

class TaskLineChartWidget extends StatefulWidget {
  const TaskLineChartWidget({super.key, required this.isDark});
  final bool isDark;

  @override
  State<TaskLineChartWidget> createState() => _TaskLineChartWidgetState();
}

class _TaskLineChartWidgetState extends State<TaskLineChartWidget> {
  _Filter _filter = _Filter.day;

  List<TaskModel> _applyFilter(List<TaskModel> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return tasks.where((t) {
      final created = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
      return switch (_filter) {
        _Filter.day   => created == today,
        _Filter.week  => !created.isBefore(today.subtract(const Duration(days: 6))) &&
            !created.isAfter(today),
        _Filter.month => !created.isBefore(today.subtract(const Duration(days: 29))) &&
            !created.isAfter(today),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final textColor  = isDark ? Colors.white : kTextDark;
    final labelColor = isDark ? Colors.grey[400]! : kTextMuted;
    final chipBg     = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04);

    return Obx(() {
      final taskCtrl = Get.find<TaskController>();
      final filtered   = _applyFilter(taskCtrl.tasks);
      final pending    = filtered.where((t) => t.status == TaskStatus.todo).length;
      final inProgress = filtered.where((t) => t.status == TaskStatus.inProgress).length;
      final done       = filtered.where((t) => t.status == TaskStatus.done).length;
      final fail       = filtered.where((t) => t.status == TaskStatus.fail).length;
      final total = pending + inProgress + done + fail;

      final data = [
        _StatusData('Pending',     pending,    kMediumPriority),
        _StatusData('In Progress', inProgress, kPrimary),
        _StatusData('Complete',    done,       kLowPriority),
        _StatusData('Fail',        fail,       kHighPriority),
      ];
      final chartData = data.where((d) => d.value > 0).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title + Filter dropdown ──────────────────────
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
                  child: DropdownButton<_Filter>(
                    value: _filter,
                    isDense: true,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: labelColor),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    dropdownColor: isDark ? const Color(0xFF2A2A3A) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    items: const [
                      DropdownMenuItem(value: _Filter.day,   child: Text('Day')),
                      DropdownMenuItem(value: _Filter.week,  child: Text('Week')),
                      DropdownMenuItem(value: _Filter.month, child: Text('Month')),
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
            style: TextStyle(fontSize: 12, color: labelColor),
          ),
          const SizedBox(height: 16),

          // ── Chart + Legend ───────────────────────────────
          Row(
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: total == 0
                    ? Center(
                        child: Text(
                          'No data',
                          style: TextStyle(color: labelColor, fontSize: 13),
                        ),
                      )
                    : SfCircularChart(
                        margin: EdgeInsets.zero,
                        annotations: <CircularChartAnnotation>[
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
                                    color: labelColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        series: <CircularSeries>[
                          DoughnutSeries<_StatusData, String>(
                            dataSource: chartData,
                            xValueMapper: (d, _) => d.label,
                            yValueMapper: (d, _) => d.value.toDouble(),
                            pointColorMapper: (d, _) => d.color,
                            innerRadius: '65%',
                            radius: '100%',
                            dataLabelSettings: const DataLabelSettings(isVisible: false),
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
                  children: data.map((d) => _LegendItem(
                    isDark: isDark,
                    color: d.color,
                    label: d.label,
                    count: d.value,
                    total: total,
                  )).toList(),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.isDark,
    required this.color,
    required this.label,
    required this.count,
    required this.total,
  });

  final bool isDark;
  final Color color;
  final String label;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : ((count / total) * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
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
      ),
    );
  }
}

class _StatusData {
  const _StatusData(this.label, this.value, this.color);
  final String label;
  final int value;
  final Color color;
}
