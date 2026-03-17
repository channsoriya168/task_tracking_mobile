import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee/employee_avatar_widget.dart';

// ── Avatar ─────────────────────────────────────────────────────
/// Circular avatar that shows [imagePath] when available,
/// falling back to the employee's initials.


// ── Card Content Row ───────────────────────────────────────────
/// Shared inner row layout for employee cards (avatar + info + trailing icon).
/// Used in both the mobile list card and the tablet grid card.
class EmployeeCardContent extends StatelessWidget {
  const EmployeeCardContent({
    super.key,
    required this.employee,
    required this.accentColor,
    required this.isDark,
    required this.avatarRadius,
    required this.nameFontSize,
    required this.emailFontSize,
    required this.trailingIcon,
    this.taskGroup,
    this.clampText = false,
  });

  final Employee employee;
  final Color accentColor;
  final bool isDark;
  final double avatarRadius;
  final double nameFontSize;
  final double emailFontSize;
  final IconData trailingIcon;

  /// When set, shows a colored position badge below the email.
  final TaskGroup? taskGroup;

  /// When true, text is limited to 1 line with ellipsis (tablet grid).
  final bool clampText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        EmployeeAvatarWidget(
          name: employee.fullName,
          color: accentColor,
          radius: avatarRadius,
          imagePath: employee.profileImageUrl,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                employee.fullName,
                maxLines: clampText ? 1 : null,
                overflow: clampText ? TextOverflow.ellipsis : null,
                style: TextStyle(
                  fontSize: nameFontSize,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : kTextDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                employee.email,
                maxLines: clampText ? 1 : null,
                overflow: clampText ? TextOverflow.ellipsis : null,
                style: TextStyle(
                  fontSize: emailFontSize,
                  color: isDark ? Colors.grey[500] : kTextMuted,
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
                    color: accentColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    taskGroup!.name,
                    style: TextStyle(
                      fontSize: 10,
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Icon(
          trailingIcon,
          size: 16,
          color: isDark ? Colors.grey[600] : Colors.grey[400],
        ),
      ],
    );
  }
}

// ── Task Group Filter Dropdown ─────────────────────────────────
/// Filter dropdown shared by the mobile and tablet employee pages.
/// Shows an "All Task Groups" sentinel item followed by each group
/// with a colored circle indicator.
class EmployeeTaskGroupDropdown extends StatelessWidget {
  const EmployeeTaskGroupDropdown({
    super.key,
    required this.isDark,
    required this.ctrl,
  });

  final bool isDark;
  final EmployeeController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Obx(() {
        final groups = ctrl.taskGroups.toList();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? kCardDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: ctrl.selectedTaskGroupId.value,
              dropdownColor: isDark ? kCardDark : Colors.white,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? Colors.grey[500] : kTextMuted,
              ),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : kTextDark,
              ),
              items: [
                DropdownMenuItem(
                  value: '',
                  child: Row(
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 18,
                        color: isDark ? Colors.grey[500] : kTextMuted,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'All Task Groups',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : kTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                ...groups.map(
                  (g) => DropdownMenuItem(
                    value: g.id,
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: g.color ?? kPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(g.name),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: (val) => ctrl.selectedTaskGroupId.value = val ?? '',
            ),
          ),
        );
      }),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────
String employeeInitials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}
