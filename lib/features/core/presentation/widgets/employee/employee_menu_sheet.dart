import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/format_date.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
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
        if (await confirmDeleteEmployee(context, name))
          menuCtrl.deleteEmployee();
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

      final bgColor = isDark ? kCardDark : const Color(0xFFF8F9FB);
      final cardColor = isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.white;
      final textColor = isDark ? Colors.white : kTextDark;
      final mutedColor = isDark ? Colors.white38 : kTextMuted;
      final protected = menuCtrl.isProtectedFromCurrentUser;

      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Top bar: title + close ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 12, 0),
              child: Row(
                children: [
                  Text(
                    'employee_menu_title'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: Get.back,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Profile card ───────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              EmployeeAvatarWidget(
                                name: emp.fullName,
                                color: accentColor,
                                radius: 32,
                                imagePath: emp.profileImageUrl,
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
                                    fontSize: 16,
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
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    if (emp.role != null &&
                                        emp.role!.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      _StatusBadge(
                                        label: emp.role!,
                                        color: accentColor,
                                        isDark: isDark,
                                      ),
                                    ],
                                    if (emp.groups.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      _StatusBadge(
                                        label: emp.groups.first.groupName,
                                        color: accentColor,
                                        isDark: isDark,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Info section card ──────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Column(
                        children: [
                          if (emp.phone != null)
                            _InfoTile(
                              icon: Icons.phone_outlined,
                              label: 'profile_phone'.tr,
                              value: emp.phone!,
                              mutedColor: mutedColor,
                              textColor: textColor,
                              isDark: isDark,
                              showDivider: true,
                            ),
                          if (emp.dateOfBirth != null)
                            _InfoTile(
                              icon: Icons.cake_outlined,
                              label: 'profile_date_of_birth'.tr,
                              value: formatDate(emp.dateOfBirth!),
                              mutedColor: mutedColor,
                              textColor: textColor,
                              isDark: isDark,
                              showDivider: true,
                            ),
                          if (emp.placeOfBirth != null)
                            _InfoTile(
                              icon: Icons.location_on_outlined,
                              label: 'profile_place_of_birth'.tr,
                              value: emp.placeOfBirth!,
                              mutedColor: mutedColor,
                              textColor: textColor,
                              isDark: isDark,
                              showDivider: true,
                            ),
                          _InfoTile(
                            icon: Icons.calendar_today_outlined,
                            label: 'employee_menu_joined'.tr,
                            value: formatDate(emp.createdAt),
                            mutedColor: mutedColor,
                            textColor: textColor,
                            isDark: isDark,
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),

                    // ── Actions ────────────────────────────────────
                    if (menuCtrl.menuItems.isNotEmpty) ...[
                      const SizedBox(height: 16),

                      // Change Password — full width
                      _ActionTile(
                        icon: Icons.lock_reset_rounded,
                        label: 'profile_change_password'.tr,
                        color: const Color(0xFFF59E0B),
                        isDark: isDark,
                        cardColor: cardColor,
                        onTap: () => _handleAction(
                          context,
                          EmployeeMenuAction.changePassword,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _ActionTile(
                              icon: Icons.edit_rounded,
                              label: 'action_edit'.tr,
                              color: kPrimary,
                              isDark: isDark,
                              cardColor: cardColor,
                              onTap: () => _handleAction(
                                context,
                                EmployeeMenuAction.edit,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ActionTile(
                              icon: Icons.delete_outline_rounded,
                              label: 'action_delete'.tr,
                              color: const Color(0xFFEF4444),
                              isDark: isDark,
                              cardColor: cardColor,
                              onTap: () => _handleAction(
                                context,
                                EmployeeMenuAction.delete,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // ── Permission notice ──────────────────────────
                    if (protected) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(
                            alpha: isDark ? 0.12 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.lock_outline_rounded,
                                size: 16,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'employee_menu_no_permission'.tr,
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

// ── Status badge ────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.isDark,
  });

  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.35 : 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ── Info tile ────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    this.iconColor = kPrimary,
    this.iconBg = kPrimary,
    required this.label,
    required this.value,
    required this.mutedColor,
    required this.textColor,
    required this.isDark,
    required this.showDivider,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final Color mutedColor;
  final Color textColor;
  final bool isDark;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
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
        if (showDivider)
          Divider(
            height: 1,
            indent: 62,
            endIndent: 14,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.05),
          ),
      ],
    );
  }
}

// ── Action tile ────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.cardColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final Color cardColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.3 : 0.18),
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: color.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: color.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
