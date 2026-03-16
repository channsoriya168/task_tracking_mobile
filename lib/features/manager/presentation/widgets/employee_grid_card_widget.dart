// ── Employee Grid Card ────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_menu_sheet.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_widgets.dart';

class EmployeeGridCardWidget extends StatelessWidget {
  const EmployeeGridCardWidget({
    required this.isDark,
    required this.ctrl,
    required this.employee,
    required this.taskGroup,
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
        employee: employee,
        ctrl: ctrl,
        isDark: isDark,
        accentColor: accent,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 35 : 8),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            EmployeeAvatar(
              name: employee.fullName,
              color: accent,
              radius: 20,
              imagePath: employee.profileImageUrl,
            ),
            const SizedBox(width: 10),

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
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : kTextDark,
                    ),
                  ),
                  if (taskGroup != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withAlpha(28),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        taskGroup!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Icon(
              Icons.more_vert_rounded,
              size: 16,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}