import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_profile_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/admin_profile_widgets.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminProfileController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: kPagePadding,
              child: Text(
                'Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : kTextDark,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AdminProfileHeader(
              isDark: isDark,
              name: ctrl.displayName,
              phone: ctrl.phoneNumber,
              avatarLetter: ctrl.avatarLetter,
            ),
          ),
          SliverToBoxAdapter(child: AdminProfileSettings(isDark: isDark)),
          SliverToBoxAdapter(
            child: AdminProfileSignOut(onTap: ctrl.confirmSignOut),
          ),
        ],
      ),
    );
  }
}
