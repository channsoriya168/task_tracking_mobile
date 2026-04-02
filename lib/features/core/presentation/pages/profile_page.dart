import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/profile/profile_action_card.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/profile/profile_group_card.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/profile/profile_group_empty_state.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/profile/profile_header.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/profile/profile_image_options_sheet.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/profile/profile_info_card.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/profile/profile_settings_card.dart';

/// Shared profile page used by all user roles (Employee, Manager, Admin).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: ColoredBox(
        color: isDark ? kBgDark : kBgLight,
        child: CustomScrollView(
          slivers: [
            // ── Title ─────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
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

            // ── Profile header ─────────────────────────────────────
            SliverPadding(
              padding: kPagePadding,
              sliver: SliverToBoxAdapter(
                child: Obx(() {
                  final authCtrl = Get.find<AuthController>();
                  final auth = authCtrl.currentAuth.value;
                  final profile = authCtrl.profile.value;
                  final name = profile?.fullName ?? auth?.fullName ?? '';
                  final role = profile?.primaryRole ?? auth?.primaryRole ?? '';
                  final email = profile?.email ?? '';
                  final avatarLetter =
                      name.isNotEmpty ? name[0].toUpperCase() : '?';
                  return ProfileHeader(
                    isDark: isDark,
                    name: name,
                    role: role,
                    email: email,
                    avatarLetter: avatarLetter,
                    profileImageUrl: profile?.profileImageUrl,
                    isUploadingImage: authCtrl.isUploadingImage.value,
                    onEditTap: () => showProfileImageOptions(isDark, authCtrl),
                  );
                }),
              ),
            ),

            // ── My Groups ──────────────────────────────────────────
            SliverPadding(
              padding: kPageSectionLargePadding,
              sliver: SliverToBoxAdapter(
                child: Text(
                  'My Groups',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: kPageSectionPadding,
              sliver: SliverToBoxAdapter(
                child: Obx(() {
                  final profile = Get.find<AuthController>().profile.value;
                  final groups = profile?.taskGroups ?? [];
                  if (groups.isEmpty) {
                    return ProfileGroupEmptyState(isDark: isDark);
                  }
                  return Column(
                    children: groups.map((g) {
                      final map = g as Map<String, dynamic>? ?? {};
                      return ProfileGroupCard(isDark: isDark, group: map);
                    }).toList(),
                  );
                }),
              ),
            ),

            // ── Personal Info ──────────────────────────────────────
            SliverPadding(
              padding: kPageSectionLargePadding,
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Personal Info',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: kPageSectionPadding,
              sliver: SliverToBoxAdapter(
                child: Obx(() {
                  final auth = Get.find<AuthController>().currentAuth.value;
                  final profile = Get.find<AuthController>().profile.value;
                  return ProfileInfoCard(
                    isDark: isDark,
                    fullName: profile?.fullName ?? auth?.fullName ?? '',
                    email: profile?.email ?? '',
                    phone: profile?.phoneNumber ?? auth?.phoneNumber ?? '',
                    placeOfBirth: profile?.placeOfBirth ?? '',
                    dateOfBirth: profile?.dateOfBirth,
                  );
                }),
              ),
            ),

            // ── Settings ───────────────────────────────────────────
            SliverPadding(
              padding: kPageSectionLargePadding,
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: kPageSectionPadding,
              sliver: SliverToBoxAdapter(
                child: ProfileSettingsCard(isDark: isDark),
              ),
            ),

            // ── Account ────────────────────────────────────────────
            SliverPadding(
              padding: kPageSectionLargePadding,
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: kPageSectionPadding,
              sliver: SliverToBoxAdapter(
                child: ProfileActionCard(isDark: isDark),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
          ],
        ),
      ),
    );
  }
}
