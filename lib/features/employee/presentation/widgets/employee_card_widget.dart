// ── Employee Card + Role Badge ────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/enums/user_role.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/employee/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/employee_menu_sheet.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/group_chip_widget.dart';
import 'package:task_tracking_mobile/features/group/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/employee/data/models/employee_menu_item.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/employee_avatar_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/employee_menu_dialogs.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/employee_reset_password_sheet.dart';

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
  final Group? taskGroup;

  Future<void> _handleMenuAction(
    BuildContext context,
    EmployeeMenuAction action,
  ) async {
    switch (action) {
      case EmployeeMenuAction.edit:
        ctrl.showEditDialog(employee);
      case EmployeeMenuAction.changePassword:
        showResetPasswordSheet(
          context,
          employee: employee,
          ctrl: ctrl,
          isDark: isDark,
        );
      case EmployeeMenuAction.delete:
        if (await confirmDeleteEmployee(context, employee.fullName)) {
          ctrl.deleteEmployee(employee.id);
        }
    }
  }

  bool get _isProtected {
    final authRole = Get.find<AuthController>().role;
    if (authRole != UserRole.manager) return false;
    final r = employee.role?.toLowerCase() ?? '';
    return r == 'manager' || r == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    const accent = kPrimary;
    final protected = _isProtected;
    final hasPhone = employee.phone != null && employee.phone!.isNotEmpty;
    final hasGroups = employee.groups.isNotEmpty || taskGroup != null;

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
                color: kPrimary.withAlpha(18),
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
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.white.withAlpha(18) : Colors.white,
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withAlpha(30)
                            : kPrimary.withAlpha(40),
                        width: 2,
                      ),
                    ),
                    child: EmployeeAvatarWidget(
                      name: employee.fullName,
                      color: kPrimary,
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
                            letterSpacing: kLs(0.1),
                          ),
                        ),
                      ),
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
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        employee.role ?? 'employee_no_role'.tr,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: accent,
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
                              fontSize: 11,
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
                        if (employee.groups.isNotEmpty)
                          ...employee.groups
                              .take(2)
                              .map(
                                (g) => GroupChipWidget(
                                  name: g.groupName,
                                  isDark: isDark,
                                ),
                              )
                        else if (taskGroup != null)
                          GroupChipWidget(
                            name: taskGroup!.name,
                            isDark: isDark,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ── Menu button ───────────────────────────────────
            if (!protected)
              PopupMenuButton<EmployeeMenuAction>(
                onSelected: (action) => _handleMenuAction(context, action),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: isDark ? kCardDark : Colors.white,
                elevation: 4,
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: EmployeeMenuAction.changePassword,
                    child: _PopupItem(
                      icon: Icons.lock_reset_rounded,
                      label: 'profile_change_password'.tr,
                      color: const Color(0xFFF59E0B),
                      isDark: isDark,
                    ),
                  ),
                  PopupMenuItem(
                    value: EmployeeMenuAction.edit,
                    child: _PopupItem(
                      icon: Icons.edit_rounded,
                      label: 'action_edit'.tr,
                      color: kPrimary,
                      isDark: isDark,
                    ),
                  ),
                  PopupMenuItem(
                    value: EmployeeMenuAction.delete,
                    child: _PopupItem(
                      icon: Icons.delete_outline_rounded,
                      label: 'action_delete'.tr,
                      color: const Color(0xFFEF4444),
                      isDark: isDark,
                    ),
                  ),
                ],
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withAlpha(10)
                        : Colors.grey.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Popup menu item row ──────────────────────────────────────────
class _PopupItem extends StatelessWidget {
  const _PopupItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
