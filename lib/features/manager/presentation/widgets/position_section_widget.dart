// ── Position Section ──────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_card_widget.dart';

class PositionSectionWidget extends StatefulWidget {
  const PositionSectionWidget({
    required this.isDark,
    required this.ctrl,
    required this.position,
    required this.employees,
  });

  final bool isDark;
  final EmployeeController ctrl;
  final Position position;
  final List<Employee> employees;

  @override
  State<PositionSectionWidget> createState() => _PositionSectionState();
}

class _PositionSectionState extends State<PositionSectionWidget> {
  bool _expanded = true;

  bool get isDark => widget.isDark;

  @override
  Widget build(BuildContext context) {
    final p = widget.position;
    final emps = widget.employees;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: p.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  p.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.grey[300] : kTextMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                //employee card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: p.color.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${emps.length}',
                    style: TextStyle(
                      fontSize: 11,
                      color: p.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: isDark ? Colors.grey[500] : kTextMuted,
                ),
              ],
            ),
          ),
        ),

        if (_expanded)
          ...emps.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: EmployeeCardWidget(
                isDark: isDark,
                ctrl: widget.ctrl,
                employee: e,
                position: p,
              ),
            ),
          ),

        if (_expanded && emps.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 4),
            child: Text(
              'No employees in this position',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[600] : kTextMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        const SizedBox(height: 4),
      ],
    );
  }
}
