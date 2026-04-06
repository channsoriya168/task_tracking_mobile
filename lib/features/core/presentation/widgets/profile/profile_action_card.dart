import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/enums/user_role.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/confirm_delete_dialog_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/profile/profile_action_row.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/profile/profile_card.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/profile/profile_change_password_sheet.dart';

class ProfileActionCard extends StatelessWidget {
  const ProfileActionCard({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final isEmployee = authCtrl.role == UserRole.employee;

    return ProfileCard(
      isDark: isDark,
      child: Column(
        children: [
          if (!isEmployee)
            ProfileActionRow(
              isDark: isDark,
              icon: Icons.lock_outline_rounded,
              iconColor: const Color(0xFF6C63FF),
              label: 'profile_change_password'.tr,
              showDivider: true,
              onTap: () {
                authCtrl.clearChangePasswordForm();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => ProfileChangePasswordSheet(isDark: isDark),
                );
              },
            ),
          ProfileActionRow(
            isDark: isDark,
            icon: Icons.logout_rounded,
            iconColor: kHighPriority,
            label: 'profile_sign_out'.tr,
            labelColor: kHighPriority,
            showDivider: false,
            onTap: () async {
              final confirmed = await showConfirmDeleteDialog(
                context,
                title: 'signout_title'.tr,
                message: 'signout_message'.tr,
                confirmText: 'signout_confirm'.tr,
              );
              if (confirmed == true) Get.find<AuthController>().logout();
            },
          ),
        ],
      ),
    );
  }
}
