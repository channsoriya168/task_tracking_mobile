import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _tokenKey = 'auth_token';
const _userKey = 'auth_user';

class StorageService {
  final _storage = const FlutterSecureStorage();

  // ── Token ──────────────────────────────────────────────
  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  // ── User JSON ──────────────────────────────────────────
  Future<void> saveUser(String userJson) =>
      _storage.write(key: _userKey, value: userJson);

  Future<String?> readUser() => _storage.read(key: _userKey);

  Future<void> deleteUser() => _storage.delete(key: _userKey);

  // ── Clear all ──────────────────────────────────────────
  Future<void> clearAll() => _storage.deleteAll();
}
