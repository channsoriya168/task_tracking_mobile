import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

class AppSnackbar {
  AppSnackbar._();

  static void success(String title, String message) =>
      _show(title, message, kLowPriority, Icons.check_circle_rounded);

  static void update(String title, String message) =>
      _show(title, message, kPrimary, Icons.edit_rounded);

  static void delete(String title, String message) =>
      _show(title, message, kHighPriority, Icons.delete_rounded);

  static void warning(String title, String message) =>
      _show(title, message, kMediumPriority, Icons.warning_rounded);

  static void error(String title, String message) =>
      _show(title, message, kHighPriority, Icons.error_rounded);

  static void _show(String title, String message, Color color, IconData icon) {
    Future.delayed(Duration.zero, () {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: color.withAlpha(220),
        colorText: Colors.white,
        icon: Icon(icon, color: Colors.white, size: 20),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    });
  }
}
