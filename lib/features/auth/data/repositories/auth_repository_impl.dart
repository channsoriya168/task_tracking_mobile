import 'package:dio/dio.dart';
import 'package:task_tracking_mobile/app/services/storage_service.dart';
import 'package:task_tracking_mobile/app/utils/dio_error_mapper.dart';
import 'package:task_tracking_mobile/app/utils/validators.dart';
import 'package:task_tracking_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/employee_profile.dart';
import 'package:task_tracking_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'dart:developer' as developer;

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;
  final _storage = StorageService();

  AuthRepositoryImpl(this._remote);

  // ── Login ────────────────────────────────────────────────
  @override
  Future<Auth> login(String phoneNumber, String password) async {
    try {
      final auth = await _remote.login(
        Validators.toE164(phoneNumber),
        password,
      );
      await _saveSession(auth);
      return auth;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // ── Logout ───────────────────────────────────────────────
  @override
  Future<void> logout() => _storage.clearAll();

  // ── Refresh token ────────────────────────────────────────
  @override
  Future<Auth> refreshToken() async {
    try {
      final accessToken = await _storage.readToken();
      final refreshToken = await _storage.readRefreshToken();
      if (accessToken == null || refreshToken == null) {
        throw Exception('No session found');
      }
      final authUpdate = await _remote.refreshToken(accessToken, refreshToken);
      await _saveSession(authUpdate);
      return authUpdate;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // ── Fetch profile ─────────────────────────────────────────
  @override
  Future<EmployeeProfile?> fetchProfile() async {
    try {
      return await _remote.fetchProfile();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // ── Check auth ────────────────────────────────────────────
  @override
  Future<Auth> checkAuth() async {
    final expiration = await _storage.readTokenExpiration();
    if (expiration == null) throw Exception('No session found');

    if (DateTime.now().isAfter(expiration)) {
      return refreshToken();
    }

    final accessToken = await _storage.readToken();
    final storedRefreshToken = await _storage.readRefreshToken();
    final roles = await _storage.readRoles();

    if (accessToken == null || storedRefreshToken == null) {
      throw Exception('No session found');
    }

    return Auth(
      userId: '',
      fullName: '',
      phoneNumber: '',
      roles: roles,
      accessToken: accessToken,
      refreshToken: storedRefreshToken,
      accessTokenExpiration: expiration,
    );
  }

  // ── Change password ───────────────────────────────────────
  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      await _remote.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // ── Helpers ───────────────────────────────────────────────

  /// Persists all auth fields to secure storage.
  Future<void> _saveSession(Auth auth) async {
    await Future.wait([
      _storage.saveToken(auth.accessToken),
      _storage.saveRefreshToken(auth.refreshToken),
      _storage.saveTokenExpiration(auth.accessTokenExpiration),
      _storage.saveRoles(auth.roles),
    ]);
  }
}
