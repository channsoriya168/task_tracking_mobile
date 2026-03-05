// ── Employee Grid Card ────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/confirm_delete_dialog.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_dialog.dart';
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
    return GestureDetector(
      onTap: () => showEmployeeDialog(context, ctrl, isDark, employee),
      onLongPress: () async {
        final confirmed = await showConfirmDeleteDialog(
          context,
          title: 'Remove Employee',
          content: 'Remove "${employee.name}" from the team?',
        );
        if (confirmed == true) ctrl.deleteEmployee(employee.id);
      },
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
          accentColor: position?.color ?? kPrimary,
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
