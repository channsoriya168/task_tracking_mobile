import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/enums/user_role.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/confirm_delete_dialog_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/profile/change_password_sheet.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/profile/profile_shared_widgets.dart';

class ProfileActionCardWidget extends StatelessWidget {
  const ProfileActionCardWidget({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final isEmployee = authCtrl.role == UserRole.Employee;

    return ProfileCard(
      isDark: isDark,
      child: Column(
        children: [
          if (!isEmployee)
            ProfileActionRow(
              isDark: isDark,
              icon: Icons.lock_outline_rounded,
              iconColor: const Color(0xFF6C63FF),
              label: 'Change Password',
              showDivider: true,
              onTap: () {
                authCtrl.clearChangePasswordForm();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => ChangePasswordSheet(isDark: isDark),
                );
              },
            ),
          ProfileActionRow(
            isDark: isDark,
            icon: Icons.logout_rounded,
            iconColor: kHighPriority,
            label: 'Sign Out',
            labelColor: kHighPriority,
            showDivider: false,
            onTap: () async {
              final confirmed = await showConfirmDeleteDialog(
                context,
                title: 'Sign Out',
                message: 'Are you sure you want to sign out?',
                confirmText: 'Sign Out',
              );
              if (confirmed == true) Get.find<AuthController>().logout();
            },
          ),
        ],
      ),
    );
  }
}
