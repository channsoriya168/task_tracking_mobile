// ── Panel Header ──────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';

class PanelHeaderWidget extends StatelessWidget {
  const PanelHeaderWidget({
    required this.isDark,
    required this.ctrl,
    required this.selectedPositionId,
  });

  final bool isDark;
  final EmployeeController ctrl;
  final String? selectedPositionId;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pos = selectedPositionId != null
          ? ctrl.findPosition(selectedPositionId!)
          : null;
      final title = pos?.name ?? 'All Employees';
      final count = selectedPositionId == null
          ? ctrl.employees.length
          : ctrl.employeeCountByPosition(selectedPositionId!);

      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 16, 4),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
                Text(
                  '$count ${count == 1 ? 'member' : 'members'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[500] : kTextMuted,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => ctrl.showDialog(isDark, null, selectedPositionId),
              icon: const Icon(Icons.person_add_rounded, size: 16),
              label: const Text('Add Employee'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      );
    });
  }
}
