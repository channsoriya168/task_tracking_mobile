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