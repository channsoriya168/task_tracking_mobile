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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : kTextDark,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

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
                  'profile_title'.tr,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                    letterSpacing: -0.3,
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
                  final avatarLetter = name.isNotEmpty
                      ? name[0].toUpperCase()
                      : '?';
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
            if (Get.find<AuthController>()
                    .profile
                    .value
                    ?.groups
                    .isNotEmpty ??
                false)
              SliverPadding(
                padding: kPageSectionLargePadding,
                sliver: SliverToBoxAdapter(
                  child: _SectionTitle(
                    label: 'profile_my_groups'.tr,
                    isDark: isDark,
                  ),
                ),
              ),
            if (Get.find<AuthController>()
                    .profile
                    .value
                    ?.groups
                    .isNotEmpty ??
                false)
              SliverPadding(
                padding: kPageSectionPadding,
                sliver: SliverToBoxAdapter(
                  child: Obx(() {
                    final profile = Get.find<AuthController>().profile.value;
                    final groups = profile?.groups ?? [];
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
                child: _SectionTitle(
                  label: 'profile_personal_info'.tr,
                  isDark: isDark,
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
                child: _SectionTitle(
                  label: 'profile_settings'.tr,
                  isDark: isDark,
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
                child: _SectionTitle(
                  label: 'profile_account'.tr,
                  isDark: isDark,
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
