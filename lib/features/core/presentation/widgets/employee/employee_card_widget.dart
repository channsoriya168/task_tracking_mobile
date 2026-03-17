// ── Employee Card + Role Badge ────────────────────────────────
import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_avatar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_menu_sheet.dart';

class EmployeeCardWidget extends StatelessWidget {
  const EmployeeCardWidget({
    required this.isDark,
    required this.ctrl,
    required this.employee,
    this.taskGroup,
  });

  final bool isDark;
  final EmployeeController ctrl;
  final Employee employee;
  final TaskGroup? taskGroup;

  @override
  Widget build(BuildContext context) {
    final accent = taskGroup?.color ?? kPrimary;
    return GestureDetector(
      onTap: () => showEmployeeMenuSheet(
        context,
        employeeId: employee.id,
        ctrl: ctrl,
        isDark: isDark,
        accentColor: accent,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 35 : 10),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            EmployeeAvatarWidget(
              name: employee.fullName,
              color: accent,
              radius: 24,
              imagePath: employee.profileImageUrl,
            ),
            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    employee.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : kTextDark,
                    ),
                  ),
                  if (employee.email.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      employee.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : kTextMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (employee.role != null &&
                          employee.role!.isNotEmpty) ...[
                        _RoleBadge(role: employee.role!),
                        const SizedBox(width: 6),
                      ],
                      if (taskGroup != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withAlpha(28),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            taskGroup!.name,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: accent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isDark ? Colors.grey[600] : Colors.grey[350],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  static Color _badgeColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const Color(0xFFEF4444);
      case 'manager':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF10B981);
    }
  }

  static String _label(String role) {
    final r = role.toLowerCase();
    if (r == 'admin') return 'Admin';
    if (r == 'manager') return 'Manager';
    return 'Employee';
  }

  @override
  Widget build(BuildContext context) {
    final color = _badgeColor(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        _label(role),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
