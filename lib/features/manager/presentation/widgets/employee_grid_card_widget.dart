// ── Employee Grid Card ────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_menu_sheet.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_widgets.dart';

class EmployeeGridCardWidget extends StatelessWidget {
  const EmployeeGridCardWidget({
    required this.isDark,
    required this.ctrl,
    required this.employee,
    required this.position,
  });

  final bool isDark;
  final EmployeeController ctrl;
  final Employee employee;
  final Position? position;

  @override
  Widget build(BuildContext context) {
    final accentColor = position?.color ?? kPrimary;
    return GestureDetector(
      onTap: () => showEmployeeMenuSheet(
        context,
        employee: employee,
        ctrl: ctrl,
        isDark: isDark,
        accentColor: accentColor,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 35 : 8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: EmployeeCardContent(
          employee: employee,
          accentColor: accentColor,
          isDark: isDark,
          avatarRadius: 20,
          nameFontSize: 13,
          emailFontSize: 11,
          trailingIcon: Icons.more_vert_rounded,
          position: position,
          clampText: true,
        ),
      ),
    );
  }
}