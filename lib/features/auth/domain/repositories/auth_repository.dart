import 'dart:io';

import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/employee_profile.dart';

abstract interface class AuthRepository {
  Future<Auth> login(String phoneNumber, String password);
  Future<void> logout();
  Future<Auth> refreshToken();
  Future<EmployeeProfile?> fetchProfile();
  Future<Auth> checkAuth();
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  });
  Future<void> updateProfile({File? image, bool removeImage = false});
}
