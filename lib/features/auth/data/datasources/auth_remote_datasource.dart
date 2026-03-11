import 'package:dio/dio.dart';
import 'package:task_tracking_mobile/app/services/api_client.dart';
import 'package:task_tracking_mobile/app/utils/api_endpoints.dart';
import 'package:task_tracking_mobile/features/auth/data/models/auth_model.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';

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
}
