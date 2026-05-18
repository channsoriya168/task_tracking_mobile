import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeStorage {
  static const _key = 'is_dark';
  final _storage = FlutterSecureStorage();

  Future<bool?> loadIsDark() async {
    final val = await _storage.read(key: _key);
    if (val == null) return null;
    return val == 'true';
  }

  Future<void> saveIsDark(bool isDark) async {
    await _storage.write(key: _key, value: isDark.toString());
  }
}
