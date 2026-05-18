import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/task_controller.dart';

class TaskLineChartWidget extends StatelessWidget {
  const TaskLineChartWidget({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : kTextDark;
    final labelColor = isDark ? Colors.grey[400]! : kTextMuted;

    return Obx(() {
      final taskCtrl = Get.find<TaskController>();
      // allTasks is already server-filtered by the selected date — use it as-is.
      final filtered = taskCtrl.allTasks;
      int count(String name) => filtered
          .where((t) => t.status.name.toLowerCase() == name.toLowerCase())
          .length;

      final pending = count('Pending');
      final assigned = count('Assigned');
      final inProgress = count('InProgress');
      final inReview = count('InReview');
      final completed = count('Completed');
      final cancelled = count('Cancelled');
      final onHold = count('OnHold');

      final total =
          pending +
          assigned +
          inProgress +
          inReview +
          completed +
          cancelled +
          onHold;

      final data = [
        _StatusData('status_pending', pending, kMediumPriority),
        _StatusData('status_assigned', assigned, const Color(0xFF00BCD4)),
        _StatusData('status_inprogress', inProgress, kPrimary),
        _StatusData('status_inreview', inReview, const Color(0xFFAB47BC)),
        _StatusData('status_completed', completed, kLowPriority),
        _StatusData('status_cancelled', cancelled, kHighPriority),
        _StatusData('status_onhold', onHold, const Color(0xFF8E8EA0)),
      ];
      final chartData = data.where((d) => d.value > 0).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ───────────────────────────────────────
          Text(
            'dashboard_task_summary'.tr,
            style: AppTextStyles.title(color: textColor),
          ),

          const SizedBox(height: 4),
          Text(
            'dashboard_total_tasks'.trParams({'count': '$total'}),
            style: AppTextStyles.subTitle(color: labelColor),
          ),
          const SizedBox(height: 16),

          // ── Chart + Legend ───────────────────────────────
          Row(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: total == 0
                    ? Center(
                        child: Text(
                          'dashboard_no_data'.tr,
                          style: AppTextStyles.subTitle(color: labelColor),
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
                                  style: AppTextStyles.title(color: textColor),
                                ),
                                Text(
                                  'task_title'.tr,
                                  style: AppTextStyles.subTitle(
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
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: false,
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(width: 14),

              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: data
                      .map(
                        (d) => _LegendItem(
                          isDark: isDark,
                          color: d.color,
                          label: d.label,
                          count: d.value,
                          total: total,
                        ),
                      )
                      .toList(),
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
              label.tr,
              style: AppTextStyles.subTitle(
                color: isDark ? Colors.white70 : kTextMuted,
              ),
            ),
          ),
          Text(
            '$count  ($pct%)',
            style: AppTextStyles.subTitle(
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
