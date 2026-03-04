import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/data/models/task_model.dart';
import 'package:task_tracking_mobile/presentation/controllers/task_controller.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TaskController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Obx(
        () => CustomScrollView(
          slivers: [
            // ── Header ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
              ),
            ),

            // ── Completion ring ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? kCardDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text('Overall Completion',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : kTextMuted)),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: ctrl.completionRate,
                              strokeWidth: 12,
                              backgroundColor:
                                  isDark ? Colors.white12 : Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  kPrimary),
                              strokeCap: StrokeCap.round,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(ctrl.completionRate * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : kTextDark,
                                  ),
                                ),
                                Text('Done',
                                    style: const TextStyle(
                                        fontSize: 12, color: kTextMuted)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _legend(kPrimary, 'Total', '${ctrl.totalTasks}'),
                          _legend(kLowPriority, 'Done',
                              '${ctrl.completedTasks}'),
                          _legend(kMediumPriority, 'Active',
                              '${ctrl.todoCount + ctrl.inReviewCount}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── By Status ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? kCardDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('By Status',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : kTextDark)),
                      const SizedBox(height: 16),
                      _bar('To Do', ctrl.todoCount, ctrl.totalTasks,
                          kTextMuted, isDark),
                      const SizedBox(height: 12),
                      _bar('In Review', ctrl.inReviewCount, ctrl.totalTasks,
                          kPrimary, isDark),
                      const SizedBox(height: 12),
                      _bar('Complete', ctrl.completedTasks, ctrl.totalTasks,
                          kLowPriority, isDark),
                    ],
                  ),
                ),
              ),
            ),

            // ── By Priority ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? kCardDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('By Priority',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : kTextDark)),
                      const SizedBox(height: 16),
                      _bar(
                          'High',
                          ctrl.tasks
                              .where((t) => t.priority == TaskPriority.high)
                              .length,
                          ctrl.totalTasks,
                          kHighPriority,
                          isDark),
                      const SizedBox(height: 12),
                      _bar(
                          'Medium',
                          ctrl.tasks
                              .where((t) => t.priority == TaskPriority.medium)
                              .length,
                          ctrl.totalTasks,
                          kMediumPriority,
                          isDark),
                      const SizedBox(height: 12),
                      _bar(
                          'Low',
                          ctrl.tasks
                              .where((t) => t.priority == TaskPriority.low)
                              .length,
                          ctrl.totalTasks,
                          kLowPriority,
                          isDark),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend(Color color, String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(fontSize: 11, color: kTextMuted)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: kTextMuted)),
      ],
    );
  }

  Widget _bar(
      String label, int count, int total, Color color, bool isDark) {
    final ratio = total == 0 ? 0.0 : count / total;
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : kTextMuted)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor:
                  isDark ? Colors.white12 : Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 24,
          child: Text('$count',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : kTextDark)),
        ),
      ],
    );
  }
}
