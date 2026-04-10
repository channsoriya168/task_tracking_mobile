import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/utils/app_snackbar.dart';

/// Returns true if the error is a connectivity failure (no internet,
/// DNS lookup failure, socket error, connection abort, etc.).
/// Use this to suppress snackbars on fetch failures when offline.
bool isConnectionError(Object e) {
  final msg = e.toString().toLowerCase();
  return msg.contains('unable to reach') ||
      msg.contains('connection') ||
      msg.contains('socket') ||
      msg.contains('network') ||
      msg.contains('host lookup') ||
      msg.contains('connection abort') ||
      msg.contains('errno = 7');
}

/// Returns true if the device is currently offline.
bool get isOffline => !Get.find<NetworkController>().isConnected.value;

/// Shows a standard "no internet" snackbar and returns true when offline.
/// Use at the top of write operations to bail out early.
///
/// Usage:
/// ```dart
/// if (guardOffline()) return false;
/// ```
bool guardOffline() {
  if (!isOffline) return false;
  AppSnackbar.error(
    'no_internet_title'.tr,
    'no_internet_subtitle'.tr,
  );
  return true;
}
