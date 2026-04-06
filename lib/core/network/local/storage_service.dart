import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _tokenKey = 'auth_token';
const _refreshTokenKey = 'auth_refresh_token';
const _accessTokenExpirationKey = 'auth_token_expiration';
const _rolesKey = 'auth_roles';

class StorageService {
  final _storage = const FlutterSecureStorage();

  // ── Access token ───────────────────────────────────────
  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  // ── Refresh token ──────────────────────────────────────
  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  // ── Token expiration ───────────────────────────────────
  Future<void> saveTokenExpiration(DateTime expiration) => _storage.write(
    key: _accessTokenExpirationKey,
    value: expiration.toUtc().toIso8601String(),
  );

  Future<DateTime?> readTokenExpiration() async {
    final value = await _storage.read(key: _accessTokenExpirationKey);
    if (value == null) return null;
    return DateTime.parse(value).toLocal();
  }

  // ── Roles ──────────────────────────────────────────────
  Future<void> saveRoles(List<String> roles) =>
      _storage.write(key: _rolesKey, value: jsonEncode(roles));

  Future<List<String>> readRoles() async {
    final value = await _storage.read(key: _rolesKey);
    if (value == null) return [];
    return (jsonDecode(value) as List).map((e) => e.toString()).toList();
  }

  // ── Clear all ──────────────────────────────────────────
  Future<void> clearAll() => _storage.deleteAll();
}
