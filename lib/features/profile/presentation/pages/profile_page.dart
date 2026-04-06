import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:task_tracking_mobile/features/profile/presentation/widgets/profile_action_card.dart';
import 'package:task_tracking_mobile/features/profile/presentation/widgets/profile_group_card.dart';
import 'package:task_tracking_mobile/features/profile/presentation/widgets/profile_group_empty_state.dart';
import 'package:task_tracking_mobile/features/profile/presentation/widgets/profile_header.dart';
import 'package:task_tracking_mobile/features/profile/presentation/widgets/profile_image_options_sheet.dart';
import 'package:task_tracking_mobile/features/profile/presentation/widgets/profile_info_card.dart';
import 'package:task_tracking_mobile/features/profile/presentation/widgets/profile_settings_card.dart';
import 'package:task_tracking_mobile/features/profile/presentation/widgets/section_title_widget.dart';

/// Shared profile page used by all user roles (Employee, Manager, Admin).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authCtrl = Get.find<AuthController>();
    final profileCtrl = Get.find<ProfileController>();

    return SafeArea(
      child: ColoredBox(
        color: isDark ? kBgDark : kBgLight,
        child: RefreshIndicator(
          onRefresh: () async {
            await profileCtrl.fetchProfile();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                    final auth = authCtrl.currentAuth.value;
                    final profile = profileCtrl.profile.value;
                    final name = profile?.fullName ?? auth?.fullName ?? '';
                    final role =
                        profile?.primaryRole ?? auth?.primaryRole ?? '';
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
                      isUploadingImage: profileCtrl.isUploadingImage.value,
                      onEditTap: () =>
                          showProfileImageOptions(isDark, profileCtrl),
                    );
                  }),
                ),
              ),

              // ── My Groups ──────────────────────────────────────────
              if (profileCtrl.profile.value?.groups.isNotEmpty ?? false)
                SliverPadding(
                  padding: kPageSectionLargePadding,
                  sliver: SliverToBoxAdapter(
                    child: SectionTitleWidget(
                      label: 'profile_my_groups'.tr,
                      isDark: isDark,
                    ),
                  ),
                ),
              if (profileCtrl.profile.value?.groups.isNotEmpty ?? false)
                SliverPadding(
                  padding: kPageSectionPadding,
                  sliver: SliverToBoxAdapter(
                    child: Obx(() {
                      final groups = profileCtrl.profile.value?.groups ?? [];
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
                  child: SectionTitleWidget(
                    label: 'profile_personal_info'.tr,
                    isDark: isDark,
                  ),
                ),
              ),
              SliverPadding(
                padding: kPageSectionPadding,
                sliver: SliverToBoxAdapter(
                  child: Obx(() {
                    final auth = authCtrl.currentAuth.value;
                    final profile = profileCtrl.profile.value;
                    return ProfileInfoCard(
                      isDark: isDark,
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
                  child: SectionTitleWidget(
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
                  child: SectionTitleWidget(
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
      ),
    );
  }
}
