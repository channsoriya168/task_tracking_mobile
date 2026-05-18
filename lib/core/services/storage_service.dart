import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:task_tracking_mobile/core/constants/storage_keys.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();

  // ── Access token ───────────────────────────────────────
  Future<void> saveToken(String token) =>
      _storage.write(key: StorageKeys.authToken, value: token);

  Future<String?> readToken() => _storage.read(key: StorageKeys.authToken);

  // ── Refresh token ──────────────────────────────────────
  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: StorageKeys.refreshToken, value: token);

  Future<String?> readRefreshToken() =>
      _storage.read(key: StorageKeys.refreshToken);

  // ── Token expiration ───────────────────────────────────
  Future<void> saveTokenExpiration(DateTime expiration) => _storage.write(
    key: StorageKeys.tokenExpiration,
    value: expiration.toUtc().toIso8601String(),
  );

  Future<DateTime?> readTokenExpiration() async {
    final value = await _storage.read(key: StorageKeys.tokenExpiration);
    if (value == null) return null;
    return DateTime.parse(value).toLocal();
  }

  // ── Roles ──────────────────────────────────────────────
  Future<void> saveRoles(List<String> roles) =>
      _storage.write(key: StorageKeys.authRoles, value: jsonEncode(roles));

  Future<List<String>> readRoles() async {
    final value = await _storage.read(key: StorageKeys.authRoles);
    if (value == null) return [];
    return (jsonDecode(value) as List).map((e) => e.toString()).toList();
  }

  // ── Clear all ──────────────────────────────────────────
  Future<void> clearAll() => _storage.deleteAll();
}
