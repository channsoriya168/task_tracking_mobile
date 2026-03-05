// ── Employee List grouped by position ─────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/position_section_widget.dart';

class EmployeeListWidget extends StatelessWidget {
  const EmployeeListWidget({required this.isDark, required this.ctrl});

  final bool isDark;
  final EmployeeController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final positions = ctrl.positions;
      if (positions.isEmpty) {
        return Center(
          child: Text(
            'No positions yet.\nTap "Positions" to add one.',
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.grey[500] : kTextMuted),
          ),
        );
      }

      final sections = positions
          .map((p) => (p, ctrl.employeesByPosition(p.id)))
          .where((s) => s.$2.isNotEmpty || ctrl.searchQuery.value.isEmpty)
          .toList();

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        itemCount: sections.length,
        itemBuilder: (_, i) {
          final (position, emps) = sections[i];
          return PositionSectionWidget(
            isDark: isDark,
            ctrl: ctrl,
            position: position,
            employees: emps,
          );
        },
      );
    });
  }
}
