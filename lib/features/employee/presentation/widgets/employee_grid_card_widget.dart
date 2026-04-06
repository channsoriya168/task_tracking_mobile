// ── Employee Grid Card ────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/employee/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/group/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/employee_avatar_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/employee_menu_sheet.dart';

class EmployeeGridCardWidget extends StatelessWidget {
  const EmployeeGridCardWidget({
    required this.isDark,
    required this.ctrl,
    required this.employee,
    required this.group,
  });

  final bool isDark;
  final EmployeeController ctrl;
  final Employee employee;
  final Group? group;

  @override
  Widget build(BuildContext context) {
    final accent = group?.color ?? kPrimary;
    return GestureDetector(
      onTap: () => showEmployeeMenuSheet(
        context,
        employeeId: employee.id,
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
            EmployeeAvatarWidget(
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
                  if (group != null) ...[
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
                        group!.name,
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
