import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';

void showProfileImageOptions(bool isDark, AuthController authCtrl) {
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
              leading: Icon(
                Icons.camera_alt,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              title: Text(
                'Camera',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              onTap: () {
                Get.back();
                authCtrl.pickAndUploadProfileImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              title: Text(
                'Gallery',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              onTap: () {
                Get.back();
                authCtrl.pickAndUploadProfileImage(ImageSource.gallery);
              },
            ),
            if (hasImage)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Remove photo',
                  style: TextStyle(color: Colors.red),
                ),
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