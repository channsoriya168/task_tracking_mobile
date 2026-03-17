import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/profile/profile_action_card_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/profile/profile_header_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/profile/profile_info_card_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/profile/profile_settings_card_widget.dart';

void _showImageOptions(bool isDark, AuthController authCtrl) {
  final hasImage = authCtrl.profile.value?.profileImageUrl?.isNotEmpty == true;
  Get.bottomSheet(
    Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.camera_alt,
                  color: isDark ? Colors.white70 : Colors.black87),
              title: Text('Camera',
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () {
                Get.back();
                authCtrl.pickAndUploadProfileImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library,
                  color: isDark ? Colors.white70 : Colors.black87),
              title: Text('Gallery',
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () {
                Get.back();
                authCtrl.pickAndUploadProfileImage(ImageSource.gallery);
              },
            ),
            if (hasImage)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remove photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Get.back();
                  authCtrl.removeProfileImage();
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
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
                  return ProfileHeaderWidget(
                    isDark: isDark,
                    name: name,
                    role: role,
                    email: email,
                    avatarLetter: avatarLetter,
                    profileImageUrl: profile?.profileImageUrl,
                    isUploadingImage: authCtrl.isUploadingImage.value,
                    onEditTap: () => _showImageOptions(isDark, authCtrl),
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
                    return _GroupEmptyState(isDark: isDark);
                  }
                  return Column(
                    children: groups.map((g) {
                      final map = g as Map<String, dynamic>? ?? {};
                      return _GroupCard(isDark: isDark, group: map);
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
                  return ProfileInfoCardWidget(
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
                child: ProfileSettingsCardWidget(isDark: isDark),
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
                child: ProfileActionCardWidget(isDark: isDark),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
          ],
        ),
      ),
    );
  }
}

// ── Group Card ─────────────────────────────────────────────────────
class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.isDark, required this.group});

  final bool isDark;
  final Map<String, dynamic> group;

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return kPrimary;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return kPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupName = group['groupName'] as String? ?? '—';
    final groupColor = _parseColor(group['groupColor'] as String?);
    final roleMap = group['role'] as Map<String, dynamic>? ?? {};
    final roleName = roleMap['name'] as String? ?? '—';
    final joinedAt = group['joinedAt'] as String?;
    final joinedDate = joinedAt != null ? DateTime.tryParse(joinedAt) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Color accent strip
              Container(
                width: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [groupColor, groupColor.withValues(alpha: 0.4)],
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Row(
                    children: [
                      // Group info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              groupName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : kTextDark,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (joinedDate != null)
                              Text(
                                'Joined ${joinedDate.day.toString().padLeft(2, '0')}/${joinedDate.month.toString().padLeft(2, '0')}/${joinedDate.year}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white38 : kTextMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Role chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: groupColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: groupColor.withAlpha(60),
                          ),
                        ),
                        child: Text(
                          roleName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: groupColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Group Empty State ──────────────────────────────────────────────
class _GroupEmptyState extends StatelessWidget {
  const _GroupEmptyState({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.group_off_rounded,
              size: 36,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 8),
            Text(
              'No groups assigned',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white38 : kTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
