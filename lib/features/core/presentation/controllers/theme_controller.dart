import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/core/data/datasources/local/theme_local_datasource.dart';

class ThemeController extends GetxController {
  final _isDark = false.obs;
  final _datasource = ThemeLocalDatasource();

  bool get isDark => _isDark.value;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final saved = await _datasource.loadIsDark();
    // Fall back to system preference if no saved value
    _isDark.value = saved ?? Get.isPlatformDarkMode;
    Get.changeThemeMode(_isDark.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggle() {
    _isDark.value = !_isDark.value;
    _datasource.saveIsDark(_isDark.value);
    Get.changeThemeMode(_isDark.value ? ThemeMode.dark : ThemeMode.light);
  }
}
