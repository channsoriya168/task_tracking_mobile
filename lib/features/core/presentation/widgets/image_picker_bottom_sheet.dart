import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  const ImagePickerBottomSheet({
    super.key,
    required this.isDark,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  final bool isDark;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                onCameraTap();
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
                onGalleryTap();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Static method to show the bottom sheet
  static void show({
    required bool isDark,
    required VoidCallback onCameraTap,
    required VoidCallback onGalleryTap,
  }) {
    Get.bottomSheet(
      ImagePickerBottomSheet(
        isDark: isDark,
        onCameraTap: onCameraTap,
        onGalleryTap: onGalleryTap,
      ),
    );
  }
}
