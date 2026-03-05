// ── Employee Card ─────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/confirm_delete_dialog.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_dialog.dart';
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
    return Dismissible(
      key: ValueKey(employee.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: kHighPriority.withAlpha(200),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 22),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => ctrl.deleteEmployee(employee.id),
      child: GestureDetector(
        onTap: () => showEmployeeDialog(context, ctrl, isDark, employee),
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
            trailingIcon: Icons.edit_rounded,
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showConfirmDeleteDialog(
      context,
      title: 'Delete Employee',
      content: 'Remove "${employee.name}" from the team?',
    );
  }
}
