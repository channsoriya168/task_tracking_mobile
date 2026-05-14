import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:task_tracking_mobile/core/network/api_client.dart';
import 'package:task_tracking_mobile/core/network/api_endpoints.dart';
import 'package:task_tracking_mobile/features/auth/data/models/auth_model.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/qr_code.dart';

class AuthRemoteDatasource {
  final Dio _dio;

  AuthRemoteDatasource() : _dio = ApiClient.instance.dio;

  /// Named constructor for tests — inject any [Dio] instance directly.
  @visibleForTesting
  AuthRemoteDatasource.withDio(this._dio);
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

  Future<Auth> qrLogin(String token) async {
    final response = await _dio.post(
      ApiEndpoints.qrLogin,
      data: {'token': token},
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
        message: data['message'] as String? ?? 'QR login failed.',
      );
    }
    return auth;
  }

  Future<QrLoginData> generateQrLogin(String employeeId) async {
    final response = await _dio.post(ApiEndpoints.generateQrLogin(employeeId));

    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }

    final data = response.data as Map<String, dynamic>;
    return QrLoginData(
      qrCodeUrl: data['qrCodeUrl'] as String? ?? '',
      expiresAt: DateTime.parse(data['expiresAt'] as String).toLocal(),
    );
  }
}
