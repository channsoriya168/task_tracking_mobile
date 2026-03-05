import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/staff/data/models/task_model.dart';
import 'package:task_tracking_mobile/features/staff/presentation/controllers/task_controller.dart';

enum _Filter { today, week, month }

class TaskLineChartWidget extends StatefulWidget {
  const TaskLineChartWidget({super.key, required this.isDark});
  final bool isDark;

  @override
  State<TaskLineChartWidget> createState() => _TaskLineChartWidgetState();
}

class _TaskLineChartWidgetState extends State<TaskLineChartWidget> {
  _Filter _filter = _Filter.today;

  List<TaskModel> _filtered(List<TaskModel> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return tasks.where((t) {
      if (t.dueDate == null) return false;
      final due = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return switch (_filter) {
        _Filter.today => due == today,
        _Filter.week  => !due.isBefore(today) &&
            due.isBefore(today.add(const Duration(days: 7))),
        _Filter.month => !due.isBefore(today) &&
            due.isBefore(today.add(const Duration(days: 30))),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final textColor = isDark ? Colors.white : kTextDark;
    final labelColor = isDark ? Colors.grey[400]! : kTextMuted;
    final chipBg = isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(8);

    return Obx(() {
      final taskCtrl = Get.find<TaskController>();
      final filtered = _filtered(taskCtrl.tasks);
      final todo       = filtered.where((t) => t.status == TaskStatus.todo).length;
      final inProgress = filtered.where((t) => t.status == TaskStatus.inProgress).length;
      final complete   = filtered.where((t) => t.status == TaskStatus.done).length;
      final total      = filtered.length;
      final pct        = total == 0 ? 0.0 : complete / total * 100;

      final data = [
        _StatusData('Todo',        todo,       const Color(0xFFFFA502)),
        _StatusData('In Progress', inProgress, kPrimary),
        _StatusData('Complete',    complete,   const Color(0xFF2ED573)),
      ];
      final chartData = data.where((d) => d.value > 0).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title + Filter dropdown ──────────────────────
          Row(
            children: [
              Text(
                'Task Status Overview',
                style: TextStyle(
                  fontSize: 16,
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
                    color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15),
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
                    items: _Filter.values.map((f) => DropdownMenuItem(
                      value: f,
                      child: Text(f.name[0].toUpperCase() + f.name.substring(1)),
                    )).toList(),
                    onChanged: (f) { if (f != null) setState(() => _filter = f); },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Chart + Legend ───────────────────────────────
          total == 0
              ? SizedBox(
                  height: 160,
                  child: Center(
                    child: Text(
                      'No tasks due in this period',
                      style: TextStyle(color: labelColor, fontSize: 13),
                    ),
                  ),
                )
              : Row(
                  children: [
                    // Doughnut
                    SizedBox(
                      width: 170,
                      height: 170,
                      child: SfCircularChart(
                        margin: EdgeInsets.zero,
                        annotations: <CircularChartAnnotation>[
                          CircularChartAnnotation(
                            widget: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${pct.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  'Done',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: labelColor,
                                    fontWeight: FontWeight.w500,
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
                            innerRadius: '62%',
                            cornerStyle: CornerStyle.bothCurve,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Legend
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: data.map((d) => _LegendRow(
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

// ── Legend Row ─────────────────────────────────────────────────
class _LegendRow extends StatelessWidget {
  const _LegendRow({
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
    final pct = total == 0 ? 0.0 : count / total;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
              ),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : kTextDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 4,
              backgroundColor: isDark
                  ? Colors.white.withAlpha(20)
                  : Colors.black.withAlpha(12),
              valueColor: AlwaysStoppedAnimation(color),
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
