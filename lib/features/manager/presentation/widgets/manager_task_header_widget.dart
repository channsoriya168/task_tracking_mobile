// ── Header ─────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/manager_task_controller.dart';

class ManagerTaskHeaderWidget extends StatelessWidget {
  const ManagerTaskHeaderWidget({
    super.key,
    required this.isDark,
    required this.ctrl,
  });

  final bool isDark;
  final ManagerTaskController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tasks',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : kTextDark,
            ),
          ),
          Obx(
            () => Text(
              '${ctrl.filteredTasks.length} of ${ctrl.tasks.length} tasks',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[500] : kTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
