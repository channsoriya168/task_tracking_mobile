import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/enums/user_role.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/confirm_delete_dialog_widget.dart';
import 'package:task_tracking_mobile/features/profile/presentation/widgets/profile_change_password_sheet.dart';

class ProfileActionCard extends StatelessWidget {
  const ProfileActionCard({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final isEmployee = authCtrl.role == UserRole.employee;

    return Column(
      children: [
        if (!isEmployee)
          _ActionRow(
            isDark: isDark,
            icon: Icons.lock_outline,
            iconColor: const Color(0xFF6C63FF),
            label: 'Change Password',
            showDivider: true,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ProfileChangePasswordSheet(isDark: isDark),
              );
            },
          ),
        _ActionRow(
          isDark: isDark,
          icon: Icons.logout_outlined,
          iconColor: kHighPriority,
          label: 'Sign Out',
          labelColor: kHighPriority,
          showDivider: false,
          onTap: () async {
            final confirmed = await showConfirmDeleteDialog(
              context,
              title: 'signout_title'.tr,
              message: 'signout_message'.tr,
              confirmText: 'signout_confirm'.tr,
            );
            if (confirmed == true) authCtrl.logout();
          },
        ),
      ],
    );
  }
}

/// Action row widget - Icon + Label + Tap action
class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color? labelColor;
  final bool showDivider;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.showDivider,
    required this.onTap,
    required this.isDark,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: iconColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: labelColor ?? (isDark ? Colors.white : kTextDark),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              height: 1,
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
          ),
      ],
    );
  }
}
