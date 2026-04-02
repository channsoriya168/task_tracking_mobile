// ── Employee Card + Role Badge ────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/enums/user_role.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_avatar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_menu_sheet.dart';

class EmployeeCardWidget extends StatelessWidget {
  const EmployeeCardWidget({
    super.key,
    required this.isDark,
    required this.ctrl,
    required this.employee,
    this.taskGroup,
  });

  final bool isDark;
  final EmployeeController ctrl;
  final Employee employee;
  final TaskGroup? taskGroup;

  bool get _isProtected {
    final authRole = Get.find<AuthController>().role;
    if (authRole != UserRole.manager) return false;
    final r = employee.role?.toLowerCase() ?? '';
    return r == 'manager' || r == 'admin';
  }

  static Color _roleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return const Color(0xFFEF4444);
      case 'manager':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF10B981);
    }
  }

  static String _roleLabel(String? role) {
    final r = role?.toLowerCase() ?? '';
    if (r == 'admin') return 'Admin';
    if (r == 'manager') return 'Manager';
    return 'Employee';
  }

  @override
  Widget build(BuildContext context) {
    final accent = taskGroup?.color ?? kPrimary;
    final protected = _isProtected;
    final hasPhone = employee.phone != null && employee.phone!.isNotEmpty;
    final roleColor = _roleColor(employee.role);
    final hasGroups = employee.taskGroups.isNotEmpty || taskGroup != null;

    return GestureDetector(
      onTap: () => showEmployeeMenuSheet(
        context,
        employeeId: employee.id,
        ctrl: ctrl,
        isDark: isDark,
        accentColor: accent,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(10)
                : Colors.grey.withAlpha(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 50 : 12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            if (!isDark)
              BoxShadow(
                color: accent.withAlpha(18),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Avatar ────────────────────────────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent.withAlpha(180),
                        accent,
                      ],
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? kCardDark : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: EmployeeAvatarWidget(
                      name: employee.fullName,
                      color: accent,
                      radius: 26,
                      imagePath: employee.profileImageUrl,
                    ),
                  ),
                ),
                if (protected)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? kCardDark : Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withAlpha(80),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // ── Info ──────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name + inactive
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          employee.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : kTextDark,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                      if (!employee.isActive) ...[
                        const SizedBox(width: 6),
                        _InactiveBadge(isDark: isDark),
                      ],
                    ],
                  ),

                  const SizedBox(height: 3),

                  // Role label (colored)
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: roleColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _roleLabel(employee.role),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: roleColor,
                        ),
                      ),
                    ],
                  ),

                  // Phone
                  if (hasPhone) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_rounded,
                          size: 11,
                          color: isDark ? Colors.grey[500] : kTextMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            employee.phone!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[400]
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Group badges
                  if (hasGroups) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        if (employee.taskGroups.isNotEmpty)
                          ...employee.taskGroups.take(2).map(
                                (g) => _GroupChip(
                                  name: g.groupName,
                                  color: g.groupColor,
                                ),
                              )
                        else if (taskGroup != null)
                          _GroupChip(
                            name: taskGroup!.name,
                            color: accent,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ── Chevron ───────────────────────────────────────
            Container(
              margin: const EdgeInsets.only(left: 8),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withAlpha(10)
                    : Colors.grey.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Inactive Badge ────────────────────────────────────────────
class _InactiveBadge extends StatelessWidget {
  const _InactiveBadge({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(isDark ? 40 : 20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withAlpha(isDark ? 60 : 40),
        ),
      ),
      child: Text(
        'Inactive',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.grey[400] : Colors.grey[500],
        ),
      ),
    );
  }
}

// ── Group Chip ────────────────────────────────────────────────
class _GroupChip extends StatelessWidget {
  const _GroupChip({required this.name, required this.color});
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
