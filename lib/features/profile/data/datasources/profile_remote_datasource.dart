import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:task_tracking_mobile/core/network/api_client.dart';
import 'package:task_tracking_mobile/core/network/api_endpoints.dart';
import 'package:task_tracking_mobile/features/profile/data/models/employee_profile_model.dart';
import 'package:task_tracking_mobile/features/profile/domain/entities/employee_profile.dart';

class ProfileRemoteDatasource {
  final Dio _dio;

  ProfileRemoteDatasource() : _dio = ApiClient.instance.dio;

  /// Named constructor for tests — inject any [Dio] instance directly.
  @visibleForTesting
  ProfileRemoteDatasource.withDio(this._dio);

  Future<EmployeeProfile?> fetchProfile() async {
    final response = await _dio.get(ApiEndpoints.profile);
    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
    final data = response.data as Map<String, dynamic>;
    return EmployeeProfileModel.fromJson(data);
  }

  Future<void> updateProfile({File? image, bool removeImage = false}) async {
    final formData = FormData.fromMap({
      if (image != null)
        'profileImage': await MultipartFile.fromFile(
          image.path,
          filename: p.basename(image.path),
        ),
      'removeProfileImage': removeImage.toString(),
    });
    final response = await _dio.patch(ApiEndpoints.profile, data: formData);
    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }
}
