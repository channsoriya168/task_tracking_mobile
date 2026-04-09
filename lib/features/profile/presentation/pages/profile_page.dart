import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
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

// ── Shimmer skeleton ───────────────────────────────────────────────────────

class _ProfileShimmer extends StatefulWidget {
  const _ProfileShimmer({required this.isDark});
  final bool isDark;

  @override
  State<_ProfileShimmer> createState() => _ProfileShimmerState();
}

class _ProfileShimmerState extends State<_ProfileShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);
    final highlight = widget.isDark
        ? Colors.white.withValues(alpha: 0.13)
        : Colors.black.withValues(alpha: 0.10);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final c = Color.lerp(base, highlight, _anim.value)!;
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title placeholder
              _Box(c: c, width: 100, height: 22),
              const SizedBox(height: 28),

              // ── Header: avatar + name/role/email ──────────────
              Row(
                children: [
                  _Box(c: c, width: 72, height: 72, radius: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Box(c: c, width: double.infinity, height: 16),
                        const SizedBox(height: 8),
                        _Box(c: c, width: 120, height: 12),
                        const SizedBox(height: 6),
                        _Box(c: c, width: 160, height: 12),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),
              Divider(height: 1, color: c),
              const SizedBox(height: 24),

              // ── Section label ─────────────────────────────────
              _Box(c: c, width: 90, height: 13),
              const SizedBox(height: 14),

              // ── Groups placeholder rows ───────────────────────
              _InfoRow(c: c),
              const SizedBox(height: 10),
              _InfoRow(c: c),
              const SizedBox(height: 28),

              // ── Personal info label ───────────────────────────
              _Box(c: c, width: 110, height: 13),
              const SizedBox(height: 14),
              _InfoRow(c: c),
              const SizedBox(height: 10),
              _InfoRow(c: c),
              const SizedBox(height: 10),
              _InfoRow(c: c),
              const SizedBox(height: 28),

              // ── Settings label ────────────────────────────────
              _Box(c: c, width: 80, height: 13),
              const SizedBox(height: 14),
              _InfoRow(c: c),
              const SizedBox(height: 10),
              _InfoRow(c: c),
            ],
          ),
        );
      },
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({
    required this.c,
    required this.width,
    required this.height,
    this.radius = 6,
  });
  final Color c;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: c,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.c});
  final Color c;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _Box(c: c, width: 20, height: 20, radius: 4),
      const SizedBox(width: 12),
      Expanded(
        child: _Box(c: c, width: double.infinity, height: 14),
      ),
    ],
  );
}

// ── Page ───────────────────────────────────────────────────────────────────

/// Shared profile page used by all user roles (Employee, Manager, Admin).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authCtrl = Get.find<AuthController>();
    final profileCtrl = Get.find<ProfileController>();
    final bg = isDark ? kBgDark : Colors.white;

    return SafeArea(
      child: ColoredBox(
        color: bg,
        child: RefreshIndicator(
          onRefresh: () async => profileCtrl.fetchProfile(),
          color: kPrimary,
          child: Obx(() {
            final offline = !Get.find<NetworkController>().isConnected.value;
            final hasNoData = profileCtrl.profile.value == null;
            final showShimmer =
                profileCtrl.isLoading.value || (offline && hasNoData);

            if (showShimmer) {
              return _ProfileShimmer(isDark: isDark);
            }

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Page title ──────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'profile_title'.tr,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : kTextDark,
                        letterSpacing: kLs(-0.6),
                      ),
                    ),
                  ),
                ),

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
      ),
    );
  }
}
