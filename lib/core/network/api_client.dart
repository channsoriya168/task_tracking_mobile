import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart' hide Response;
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'local/storage_service.dart';

class ApiClient {
  static final ApiClient instance = ApiClient._internal();
  factory ApiClient() => instance;

  late final Dio dio;
  final StorageService storage = StorageService();

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL'] ?? '',
        connectTimeout: Duration(
          milliseconds:
              int.tryParse(dotenv.env['CONNECT_TIMEOUT_MS'] ?? '') ?? 15000,
        ),
        receiveTimeout: Duration(
          milliseconds:
              int.tryParse(dotenv.env['RECEIVE_TIMEOUT_MS'] ?? '') ?? 30000,
        ),
      ),
    );

    dio.interceptors.add(_AuthInterceptor(storage: storage));
  }

  /// Create a Dio instance without interceptors (for refresh)
  static Dio createDioWithoutInterceptor() {
    return Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL'] ?? '',
        connectTimeout: Duration(
          milliseconds:
              int.tryParse(dotenv.env['CONNECT_TIMEOUT_MS'] ?? '') ?? 15000,
        ),
        receiveTimeout: Duration(
          milliseconds:
              int.tryParse(dotenv.env['RECEIVE_TIMEOUT_MS'] ?? '') ?? 30000,
        ),
      ),
    );
  }
}

/// ── Auth Interceptor ───────────────────────────────────────────────
class _AuthInterceptor extends Interceptor {
  final StorageService storage;
  bool _isRefreshing = false;
  final List<_PendingRequest> _pending = [];

  _AuthInterceptor({required this.storage});

  AuthController get _authController => Get.find<AuthController>();
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.readToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final is401 = err.response?.statusCode == 401;
    final path = err.requestOptions.path.toLowerCase();
    final isRefreshEndpoint = path.contains('/auth/refresh');
    final isLoginEndpoint = path.contains('/auth/login');
    final isChangePasswordEndpoint = path.contains('/auth/change-password');
    final alreadyRetried = err.requestOptions.extra['_retried'] == true;

    if (!is401 ||
        isRefreshEndpoint ||
        isLoginEndpoint ||
        isChangePasswordEndpoint ||
        alreadyRetried) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      _pending.add(_PendingRequest(err.requestOptions, handler));
      return;
    }

    _isRefreshing = true;
    try {
      final success = await _authController.refreshToken();
      if (!success) throw Exception('Refresh failed');

      // Retry original request
      err.requestOptions.extra['_retried'] = true;
      final retried = await ApiClient.instance.dio.fetch(err.requestOptions);
      handler.resolve(retried);

      // Retry any queued requests
      for (final p in _pending) {
        p.options.extra['_retried'] = true;
        final r = await ApiClient.instance.dio.fetch(p.options);
        p.handler.resolve(r);
      }
    } catch (_) {
      for (final p in _pending) {
        p.handler.next(
          DioException(
            requestOptions: p.options,
            type: DioExceptionType.cancel,
            error: 'Session expired',
          ),
        );
      }
      await _authController.logout();
      handler.next(err);
    } finally {
      _pending.clear();
      _isRefreshing = false;
    }
  }
}

/// Helper class for queued requests
class _PendingRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;
  _PendingRequest(this.options, this.handler);
}
