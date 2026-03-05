// ── Employee Grid Card ────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_dialogs.dart';
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
      onLongPress: () => _confirmDelete(context),
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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Employee'),
        content: Text('Remove "${employee.name}" from the team?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ctrl.deleteEmployee(employee.id);
            },
            style: TextButton.styleFrom(foregroundColor: kHighPriority),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
