import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/constants/user_role.dart';
import 'package:task_tracking_mobile/core/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/confirm_delete_dialog_widget.dart';

class ProfileActionCard extends StatelessWidget {
  const ProfileActionCard({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final isEmployee = authCtrl.role == UserRole.employee;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white12 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.white.withAlpha(10) : Colors.grey.shade200,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (!isEmployee) ...[
            Divider(
              height: 1,
              indent: 0,
              endIndent: 0,
              color: isDark ? Colors.white.withAlpha(10) : Colors.grey.shade200,
            ),
          ],
          _ActionRow(
            isDark: isDark,
            icon: Icons.logout_rounded,
            iconColor: kHighPriority,
            label: 'Sign Out',
            labelColor: kHighPriority,
            onTap: () async {
              final confirmed = await showConfirmDeleteDialog(
                context,
                title: 'signout_title'.tr,
                message: 'signout_message'.tr,
                confirmText: 'signout_confirm'.tr,
              );
              if (confirmed == true) authCtrl.logout();
              AppSnackbar.success(
                'snack_logged_out'.tr,
                'snack_logged_out_msg'.tr,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color? labelColor;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
    required this.isDark,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 16),
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
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? Colors.white24 : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
