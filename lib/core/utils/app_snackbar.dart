import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';

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

  /// Extracts a human-readable message from a backend error.
  /// Handles DioException response bodies with `message` or `errors` fields.
  static String parseApiError(Object? err, {String? fallback}) {
    if (err is DioException) {
      final data = err.response?.data;
      if (data is Map) {
        if (data['message'] is String) return data['message'] as String;

        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final messages = errors.values
              .expand(
                (v) => v is List ? v.map((e) => e.toString()) : [v.toString()],
              )
              .take(3)
              .join('\n');
          if (messages.isNotEmpty) return messages;
        }

        if (data['title'] is String) return data['title'] as String;
      }
      if (err.message != null) return err.message!;
    }
    return fallback ?? 'snack_something_wrong'.tr;
  }

  static void _show(String title, String message, Color color, IconData icon) {
    Future.delayed(Duration.zero, () {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
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
