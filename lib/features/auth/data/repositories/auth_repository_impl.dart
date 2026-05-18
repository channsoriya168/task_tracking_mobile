import 'package:dio/dio.dart';
import 'package:task_tracking_mobile/core/services/storage_service.dart';
import 'package:task_tracking_mobile/core/utils/dio_error_mapper.dart';
import 'package:task_tracking_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/qr_code.dart';
import 'package:task_tracking_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;
  final StorageService _storage;

  AuthRepositoryImpl(this._remote, [StorageService? storage])
    : _storage = storage ?? StorageService();

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
    } catch (e) {
      throw Exception(e);
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

  // ── QR Login ─────────────────────────────────────────────
  @override
  Future<Auth> qrLogin(String token) async {
    try {
      final auth = await _remote.qrLogin(token);
      await _saveSession(auth);
      return auth;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // ── Generate QR ───────────────────────────────────────────
  @override
  Future<QrLoginData> generateQrLogin(String employeeId) async {
    try {
      return await _remote.generateQrLogin(employeeId);
    } catch (e) {
      throw Exception(e);
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
