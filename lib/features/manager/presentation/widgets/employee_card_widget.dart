// ── Employee Card ─────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_menu_sheet.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_widgets.dart';

class EmployeeCardWidget extends StatelessWidget {
  const EmployeeCardWidget({
    required this.isDark,
    required this.ctrl,
    required this.employee,
    required this.position,
  });

  final bool isDark;
  final EmployeeController ctrl;
  final Employee employee;
  final Position position;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showEmployeeMenuSheet(
        context,
        employee: employee,
        ctrl: ctrl,
        isDark: isDark,
        accentColor: position.color,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 40 : 10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: EmployeeCardContent(
          employee: employee,
          accentColor: position.color,
          isDark: isDark,
          avatarRadius: 22,
          nameFontSize: 14,
          emailFontSize: 12,
          trailingIcon: Icons.more_vert_rounded,
        ),
      ),
    );
  }
}