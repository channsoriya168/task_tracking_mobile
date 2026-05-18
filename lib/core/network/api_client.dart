import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart' hide Response;
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/routes/app_routes.dart';
import '../services/storage_service.dart';

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

    dio.interceptors.add(_NetworkInterceptor());
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
  bool _isLoggingOut = false;
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

  /// Logs out once — guards against loops when logout itself triggers 403/401.
  Future<void> _forceLogout(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_isLoggingOut || Get.currentRoute == AppRoutes.login) {
      handler.next(err);
      return;
    }
    _isLoggingOut = true;
    try {
      await _authController.logout();
    } finally {
      _isLoggingOut = false;
    }
    handler.next(err);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final is401 = statusCode == 401;
    final is403 = statusCode == 403;
    final path = err.requestOptions.path.toLowerCase();
    final isRefreshEndpoint = path.contains('/auth/refresh');
    final isLoginEndpoint = path.contains('/auth/login');
    final isQrLoginEndpoint = path.contains('/auth/qr-login');
    final alreadyRetried = err.requestOptions.extra['_retried'] == true;

    // 403 Account Inactive — force logout, _isLoggingOut guard prevents loops
    if (is403) {
      final title = (err.response?.data?['title'] as String? ?? '')
          .toLowerCase();
      if (title.contains('account inactive')) {
        await _forceLogout(err, handler);
        return;
      }
    }

    if (!is401 ||
        isRefreshEndpoint ||
        isLoginEndpoint ||
        isQrLoginEndpoint ||
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
      await _forceLogout(err, handler);
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

/// ── Network Interceptor ────────────────────────────────────────────
/// Updates [NetworkController] based on real request outcomes so the
/// offline banner reflects actual server reachability, not just whether
/// a network interface is present.
class _NetworkInterceptor extends Interceptor {
  NetworkController? get _net => Get.isRegistered<NetworkController>()
      ? Get.find<NetworkController>()
      : null;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _net?.onConnectionRestored();
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      _net?.onConnectionError();
    }
    handler.next(err);
  }
}
