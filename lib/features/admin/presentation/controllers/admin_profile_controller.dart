import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';

class AdminProfileController extends GetxController {
  final _auth = Get.find<AuthController>();

  Auth? get user => _auth.currentAuth.value;
  String get displayName => user?.fullName ?? 'Admin';
  String get phoneNumber => user?.phoneNumber ?? '';
  String get avatarLetter => user?.avatarLetter ?? 'A';

  void confirmSignOut() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel', style: TextStyle(color: kTextMuted)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _auth.logout();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: kHighPriority,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
