import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_detail_widgets.dart';

class EmployeeDetailTabletPage extends StatelessWidget {
  const EmployeeDetailTabletPage({
    super.key,
    required this.emp,
    required this.ctrl,
    required this.isDark,
  });

  final Employee emp;
  final EmployeeController ctrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final pos = ctrl.findPosition(emp.positionId);
    final accentColor = pos?.color ?? kPrimary;
    final tasks = ctrl.tasksForEmployee(emp.id);

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      appBar: AppBar(
        backgroundColor: isDark ? kCardDark : Colors.white,
        foregroundColor: isDark ? Colors.white : kTextDark,
        elevation: 0,
        title: Text(
          emp.name,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: profile + info + QR ──────────────────────
          SizedBox(
            width: 380,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EmployeeDetailHeader(
                    emp: emp,
                    accentColor: accentColor,
                    isDark: isDark,
                    pos: pos,
                  ),
                  const SizedBox(height: 28),
                  EmployeeDetailSectionLabel(
                    label: 'Personal Information',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  EmployeeInfoSection(
                    emp: emp,
                    isDark: isDark,
                    accentColor: accentColor,
                    pos: pos,
                  ),
                  const SizedBox(height: 28),
                  EmployeeDetailSectionLabel(
                    label: 'Login QR Code',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  EmployeeQrSection(emp: emp, isDark: isDark),
                ],
              ),
            ),
          ),

          VerticalDivider(
            width: 1,
            thickness: 1,
            color: isDark
                ? Colors.white.withAlpha(12)
                : Colors.black.withAlpha(8),
          ),

          // ── Right: tasks ────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      EmployeeDetailSectionLabel(
                        label: 'Assigned Tasks',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimary.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${tasks.length}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: kPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  EmployeeTasksSection(tasks: tasks, isDark: isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}