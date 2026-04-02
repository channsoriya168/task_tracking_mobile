import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/format_date.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/data/models/employee_menu_item.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_menu_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_avatar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_menu_dialogs.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_reset_password_sheet.dart';

void showEmployeeMenuSheet(
  BuildContext context, {
  required EmployeeController ctrl,
  required bool isDark,
  required Color accentColor,
  required String employeeId,
}) {
  final menuCtrl = Get.put(
    EmployeeMenuController(employeeId: employeeId, isDark: isDark),
    tag: employeeId,
  );

  Get.bottomSheet(
    _EmployeeMenuSheet(
      menuCtrl: menuCtrl,
      isDark: isDark,
      accentColor: accentColor,
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  ).then((_) => Get.delete<EmployeeMenuController>(tag: employeeId));
}

class _EmployeeMenuSheet extends StatelessWidget {
  const _EmployeeMenuSheet({
    required this.menuCtrl,
    required this.isDark,
    required this.accentColor,
  });

  final EmployeeMenuController menuCtrl;
  final bool isDark;
  final Color accentColor;

  Future<void> _handleAction(
    BuildContext context,
    EmployeeMenuAction action,
  ) async {
    switch (action) {
      case EmployeeMenuAction.edit:
        menuCtrl.edit();
      case EmployeeMenuAction.changePassword:
        final emp = menuCtrl.employee;
        if (emp == null) return;
        Get.back();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showResetPasswordSheet(
            context,
            employee: emp,
            ctrl: Get.find<EmployeeController>(),
            isDark: isDark,
          );
        });
      case EmployeeMenuAction.delete:
        final name = menuCtrl.employee?.fullName ?? '';
        if (await confirmDeleteEmployee(name)) menuCtrl.deleteEmployee();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final emp = menuCtrl.employee;

      if (emp == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
        return const SizedBox.shrink();
      }

      final dividerColor = isDark
          ? Colors.white.withAlpha(10)
          : Colors.black.withAlpha(8);
      final mutedColor = isDark ? Colors.white38 : kTextMuted;
      final textColor = isDark ? Colors.white : kTextDark;
      final protected = menuCtrl.isProtectedFromCurrentUser;

      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle + close ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
              child: Row(
                children: [
                  const Spacer(),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: Get.back,
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(4),
                          minimumSize: const Size(32, 32),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header: avatar + name + role + status ──────
                    Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            EmployeeAvatarWidget(
                              name: emp.fullName,
                              color: accentColor,
                              radius: 30,
                              imagePath: emp.profileImageUrl,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: emp.isActive
                                      ? const Color(0xFF2ED573)
                                      : const Color(0xFFFF4757),
                                  border: Border.all(
                                    color: isDark ? kCardDark : Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                emp.fullName,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                emp.email,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: mutedColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  if (emp.role != null &&
                                      emp.role!.isNotEmpty) ...[
                                    _RoleBadge(role: emp.role!),
                                    const SizedBox(width: 6),
                                  ],
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: emp.isActive
                                          ? const Color(0xFF2ED573).withValues(
                                              alpha: 0.12,
                                            )
                                          : Colors.grey.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      emp.isActive ? 'Active' : 'Inactive',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: emp.isActive
                                            ? const Color(0xFF2ED573)
                                            : (isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600]),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Info rows ──────────────────────────────────
                    Divider(height: 1, color: dividerColor),
                    if (emp.phone != null)
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: emp.phone!,
                        mutedColor: mutedColor,
                        textColor: textColor,
                        dividerColor: dividerColor,
                      ),
                    if (emp.dateOfBirth != null)
                      _InfoRow(
                        icon: Icons.cake_outlined,
                        label: 'Date of Birth',
                        value: formatDate(emp.dateOfBirth!),
                        mutedColor: mutedColor,
                        textColor: textColor,
                        dividerColor: dividerColor,
                      ),
                    if (emp.placeOfBirth != null)
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Place of Birth',
                        value: emp.placeOfBirth!,
                        mutedColor: mutedColor,
                        textColor: textColor,
                        dividerColor: dividerColor,
                      ),
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Joined',
                      value: formatDate(emp.createdAt),
                      mutedColor: mutedColor,
                      textColor: textColor,
                      dividerColor: dividerColor,
                      isLast: true,
                    ),

                    // ── Actions ────────────────────────────────────
                    if (menuCtrl.menuItems.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: _ActionButton(
                          label: 'Change Password',
                          icon: Icons.lock_reset_rounded,
                          color: const Color(0xFFF59E0B),
                          isDark: isDark,
                          isFull: true,
                          onTap: () => _handleAction(context,
                              EmployeeMenuAction.changePassword),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              label: 'Edit',
                              icon: Icons.edit_rounded,
                              color: kPrimary,
                              isDark: isDark,
                              onTap: () => _handleAction(
                                  context, EmployeeMenuAction.edit),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ActionButton(
                              label: 'Delete',
                              icon: Icons.delete_rounded,
                              color: const Color(0xFFEF4444),
                              isDark: isDark,
                              onTap: () => _handleAction(
                                  context, EmployeeMenuAction.delete),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // ── Permission notice ──────────────────────────
                    if (protected) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lock_rounded,
                              size: 14,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'You do not have permission to manage this account.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.orange[200]
                                      : Colors.orange[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Info row ────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.mutedColor,
    required this.textColor,
    required this.dividerColor,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color mutedColor;
  final Color textColor;
  final Color dividerColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: mutedColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: mutedColor,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: dividerColor),
      ],
    );
  }
}

// ── Role badge ──────────────────────────────────────────────────
class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final String role;

  static Color _color(String role) {
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
    final color = _color(role);
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

// ── Action button ────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
    this.isFull = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  final bool isFull;

  @override
  Widget build(BuildContext context) {
    final bg = color.withValues(alpha: isDark ? 0.15 : 0.08);
    final border = color.withValues(alpha: isDark ? 0.35 : 0.25);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isFull ? 14 : 16,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: isFull
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 22, color: color),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
