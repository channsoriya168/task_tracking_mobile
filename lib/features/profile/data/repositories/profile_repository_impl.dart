import 'dart:io';

import 'package:dio/dio.dart';
import 'package:task_tracking_mobile/core/utils/dio_error_mapper.dart';
import 'package:task_tracking_mobile/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:task_tracking_mobile/features/profile/domain/entities/employee_profile.dart';
import 'package:task_tracking_mobile/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource _remote;

  const ProfileRepositoryImpl(this._remote);

  @override
  Future<EmployeeProfile?> fetchProfile() async {
    try {
      return await _remote.fetchProfile();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> updateProfile({File? image, bool removeImage = false}) async {
    try {
      await _remote.updateProfile(image: image, removeImage: removeImage);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
