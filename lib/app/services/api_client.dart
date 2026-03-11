import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart' hide Response;
import 'package:task_tracking_mobile/app/routes/app_routes.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'storage_service.dart';

class ApiClient {
  ApiClient._() {
    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    final connectMs =
        int.tryParse(dotenv.env['CONNECT_TIMEOUT_MS'] ?? '') ?? 15000;
    final receiveMs =
        int.tryParse(dotenv.env['RECEIVE_TIMEOUT_MS'] ?? '') ?? 30000;

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(milliseconds: connectMs),
        receiveTimeout: Duration(milliseconds: receiveMs),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Allow self-signed certs in debug only
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => kDebugMode;
      return client;
    };

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      if (kDebugMode) _LoggingInterceptor(),
    ]);
  }

  static final ApiClient instance = ApiClient._();

  late final Dio _dio;

  Dio get dio => _dio;
}

// ── Auth Interceptor ──────────────────────────────────────────────────────────
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await StorageService().readToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await StorageService().clearAll();
      if (Get.isRegistered<AuthController>()) {
        Get.find<AuthController>().currentAuth.value = null;
      }
      Get.offAllNamed(AppRoutes.login);
    }
    handler.next(err);
  }
}

// ── Logging Interceptor ───────────────────────────────────────────────────────
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[API] → ${options.method} ${options.uri}');
    debugPrint('[API] body: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('[API] ← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '[API] ✖ ${err.response?.statusCode} ${err.requestOptions.uri} — ${err.message}',
    );
    handler.next(err);
  }
}
