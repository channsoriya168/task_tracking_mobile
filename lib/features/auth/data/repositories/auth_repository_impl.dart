import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:task_tracking_mobile/app/services/storage_service.dart';
import 'package:task_tracking_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:task_tracking_mobile/features/auth/data/models/auth_model.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';
import 'package:task_tracking_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;
  final _storage = StorageService();

  AuthRepositoryImpl(this._remote);
  // ── Login ────────────────────────────────────────────────
  @override
  Future<Auth> login(String phoneNumber, String password) async {
    try {
      final auth = await _remote.login(_toE164(phoneNumber), password);
      // Save token separately; save only minimal user info locally
      await _storage.saveToken(auth.accessToken);
      await _storage.saveUser(jsonEncode(AuthModel.toLocalJson(auth)));
      return auth;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ── Restore session ──────────────────────────────────────
  @override
  Future<Auth?> restoreSession() async {
    final token = await _storage.readToken();
    final userJson = await _storage.readUser();
    if (token == null || userJson == null) return null;
    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      final auth = AuthModel.fromLocalJson(map, token);
      if (auth == null) {
        // Token expired — clean up storage
        await _storage.clearAll();
        return null;
      }
      return auth;
    } catch (_) {
      return null;
    }
  }

  // ── Logout ───────────────────────────────────────────────
  @override
  Future<void> logout() => _storage.clearAll();

  // ── Phone → E.164 (+855) ─────────────────────────────────
  /// Converts `0884311016` → `+855884311016`.
  /// Leaves numbers already starting with `+` unchanged.
  String _toE164(String phone) {
    final digits = phone.trim();
    if (digits.startsWith('+')) return digits;
    if (digits.startsWith('0')) return '+855${digits.substring(1)}';
    return '+855$digits';
  }

  // ── Dio error → readable message ─────────────────────────
  String _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Unable to reach the server. Check your connection.';
    }
    final status = e.response?.statusCode;
    if (status == 400) {
      return e.response?.data?['message'] as String? ?? 'Invalid credentials.';
    }
    if (status == 401) return 'Incorrect phone number or password.';
    if (status == 403) return 'Access denied.';
    if (status == 500) return 'Server error. Please try again later.';
    return e.response?.data?['message'] as String? ??
        e.message ??
        'Something went wrong.';
  }
}
