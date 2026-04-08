import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/profile/presentation/controllers/profile_controller.dart';

class ProfileAvatarWidget extends StatelessWidget {
  const ProfileAvatarWidget({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final authCtrl = Get.find<AuthController>();
      final profile = Get.find<ProfileController>().profile.value;
      final auth = authCtrl.currentAuth.value;
      final name = profile?.fullName ?? auth?.fullName ?? '';
      final imageUrl = profile?.profileImageUrl;
      final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';

      return AnimatedContainer(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Colors.white.withAlpha(220)
                : kPrimary.withAlpha(90),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: ClipOval(
          child: imageUrl != null && imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : kPrimary,
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : kPrimary,
                    ),
                  ),
                ),
        ),
      );
    });
  }
}
