import 'package:dio/dio.dart';
import 'package:task_tracking_mobile/app/services/api_client.dart';
import 'package:task_tracking_mobile/app/utils/api_endpoints.dart';
import 'package:task_tracking_mobile/features/auth/data/models/auth_model.dart';
import 'package:task_tracking_mobile/features/auth/data/models/employee_profile_model.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/employee_profile.dart';

class AuthRemoteDatasource {
  final Dio _dio = ApiClient.instance.dio;

  Future<Auth> login(String phoneNumber, String password) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {'phoneNumber': phoneNumber, 'password': password},
    );

    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }

    final data = response.data as Map<String, dynamic>;
    final auth = AuthModel.fromJson(data);

    if (auth.accessToken.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: data['message'] as String? ?? 'Login failed.',
      );
    }

    return auth;
  }

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

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      },
    );
    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  Future<Auth> refreshToken(String accessToken, String refreshToken) async {
    final response = await _dio.post(
      ApiEndpoints.refreshToken,
      data: {'accessToken': accessToken, 'refreshToken': refreshToken},
    );

    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }

    final data = response.data as Map<String, dynamic>;
    return AuthModel.fromJson(data);
  }
}
