import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_controller.dart';

class EmployeeFormAvatar extends StatelessWidget {
  const EmployeeFormAvatar({
    super.key,
    required this.controller,
    required this.isDark,
  });

  final EmployeeController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final img = controller.profileImage.value;
      final existingUrl = controller.existingImageUrl;
      final removed = controller.removeProfileImage.value;
      final isEdit = controller.isEditMode.value;

      ImageProvider? bgImage;
      if (img != null) {
        bgImage = FileImage(File(img.path));
      } else if (!removed && existingUrl != null && existingUrl.isNotEmpty) {
        bgImage = NetworkImage(existingUrl);
      }

      return Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: controller.pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: isDark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                    backgroundImage: bgImage,
                    child: bgImage == null
                        ? Icon(
                            Icons.person_rounded,
                            size: 44,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: kPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? kCardDark : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isEdit && bgImage != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  controller.profileImage.value = null;
                  controller.removeProfileImage.value = true;
                },
                child: Text(
                  'Remove photo',
                  style: TextStyle(
                    fontSize: 12,
                    color: kHighPriority,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}
