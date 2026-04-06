import 'dart:io';

import 'package:task_tracking_mobile/features/profile/domain/entities/employee_profile.dart';

abstract interface class ProfileRepository {
  Future<EmployeeProfile?> fetchProfile();
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  });
  Future<void> updateProfile({File? image, bool removeImage = false});
}
