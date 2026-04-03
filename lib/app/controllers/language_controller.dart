import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

const _localeKey = 'app_locale';

class LanguageController extends GetxController {
  final RxBool isKhmer;

  LanguageController({bool initialIsKhmer = false})
    : isKhmer = initialIsKhmer.obs;

  Locale get currentLocale =>
      isKhmer.value ? const Locale('km', 'KH') : const Locale('en', 'US');

  void toggleLanguage() {
    isKhmer.toggle();
    Get.updateLocale(currentLocale);
    _saveLocale();
  }

  Future<void> _saveLocale() async {
    const FlutterSecureStorage().write(
      key: _localeKey,
      value: isKhmer.value ? 'km_KH' : 'en_US',
    );
  }

  /// Call this in [main] before [runApp] to read the persisted locale.
  static Future<bool> readSavedIsKhmer() async {
    final value = await const FlutterSecureStorage().read(key: _localeKey);
    return value == 'km_KH';
  }
}
