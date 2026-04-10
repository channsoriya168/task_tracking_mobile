import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
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
import 'package:task_tracking_mobile/features/profile/presentation/widgets/profile_shimmer_widget.dart';
import 'package:task_tracking_mobile/features/profile/presentation/widgets/section_title_widget.dart';

// ── Page ───────────────────────────────────────────────────────────────────

/// Shared profile page used by all user roles (Employee, Manager, Admin).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authCtrl = Get.find<AuthController>();
    final profileCtrl = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'profile_title'.tr,
          style: AppTextStyles.appBarTitle(color: kPrimary),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => profileCtrl.fetchProfile(),
        color: kPrimary,
        child: Obx(() {
          final offline = !Get.find<NetworkController>().isConnected.value;
          final hasNoData = profileCtrl.profile.value == null;
          final showShimmer =
              profileCtrl.isLoading.value || (offline && hasNoData);

          if (showShimmer) {
            return ProfileShimmerWidget(isDark: isDark);
          }

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Profile header ─ padded, flat on bg ────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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

              // ── Full-width divider after profile ────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Divider(
                    height: 1,
                    color: isDark
                        ? Colors.white.withAlpha(12)
                        : const Color(0xFFD1D1D6),
                  ),
                ),
              ),

              // ── My Groups — label (padded) + section (full-width)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: SectionTitleWidget(
                    label: 'profile_my_groups'.tr,
                    isDark: isDark,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Obx(() {
                  final groups = profileCtrl.profile.value?.groups ?? [];
                  if (groups.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ProfileGroupEmptyState(isDark: isDark),
                    );
                  }
                  return Container(
                    color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                    child: Column(
                      children: List.generate(groups.length, (i) {
                        final map = groups[i] as Map<String, dynamic>? ?? {};
                        return Column(
                          children: [
                            ProfileGroupCard(isDark: isDark, group: map),
                            if (i < groups.length - 1)
                              Divider(
                                height: 1,
                                indent: 0,
                                endIndent: 0,
                                color: isDark
                                    ? Colors.white.withAlpha(10)
                                    : Colors.grey.shade200,
                              ),
                          ],
                        );
                      }),
                    ),
                  );
                }),
              ),

              // ── Personal Info ───────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: SectionTitleWidget(
                    label: 'profile_personal_info'.tr,
                    isDark: isDark,
                  ),
                ),
              ),
              SliverToBoxAdapter(
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

              // ── Settings ────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: SectionTitleWidget(
                    label: 'profile_settings'.tr,
                    isDark: isDark,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: ProfileSettingsCard(isDark: isDark)),

              // ── Account ─────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: SectionTitleWidget(
                    label: 'profile_account'.tr,
                    isDark: isDark,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: ProfileActionCard(isDark: isDark)),

              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          );
        }),
      ),
    );
  }
}
