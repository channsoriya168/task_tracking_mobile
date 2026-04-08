import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/enums/user_role.dart';
import 'package:task_tracking_mobile/core/network/api_client.dart';
import 'package:task_tracking_mobile/core/network/api_endpoints.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/task/domain/repositories/task_item_repository.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/employee_task_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/show_task_detail_sheet.dart';
import 'package:task_tracking_mobile/routes/app_routes.dart';

class PushNotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _currentToken;

  // ── Constants ─────────────────────────────────────────────
  static const _channelId = 'task_tracking_notifications';
  static const _channelName = 'Task Notifications';
  static const _channelDescription =
      'Notifications for task updates, comments, and reminders.';
  static const _appIcon = '@mipmap/ic_launcher';

  // ── Android Notification Channel ──────────────────────────
  static const _channel = AndroidNotificationChannel(
    _channelId,
    _channelName,
    description: _channelDescription,
    importance: Importance.high,
  );

  // ── Initialization ────────────────────────────────────────
  Future<PushNotificationService> init() async {
    await _setupAndroidChannel();
    await _setupLocalNotifications();
    await _setupIosForegroundOptions();
    _setupMessageListeners();
    await _checkInitialMessage();
    _setupTokenRefreshListener();
    return this;
  }

  Future<void> _setupAndroidChannel() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(_appIcon);
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  Future<void> _setupIosForegroundOptions() async {
    if (!Platform.isIOS) return;
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _setupMessageListeners() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);
  }

  Future<void> _checkInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      // Delay slightly to let the app initialize navigation
      Future.delayed(const Duration(seconds: 1), () {
        _handleNotificationOpen(initialMessage);
      });
    }
  }

  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((newToken) {
      if (_currentToken != null) {
        _registerTokenWithBackend(newToken);
      }
    });
  }

  // ── Permission Request ────────────────────────────────────
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  // ── Token Registration ────────────────────────────────────
  /// Call after successful login to register FCM token with backend.
  Future<void> registerToken() async {
    final granted = await requestPermission();
    if (!granted) {
      debugPrint('[FCM] Permission not granted');
      return;
    }

    final token = await _messaging.getToken();
    if (token == null) {
      debugPrint('[FCM] Failed to get token');
      return;
    }

    _currentToken = token;
    await _registerTokenWithBackend(token);
  }

  /// Call before logout to unregister FCM token from backend.
  Future<void> unregisterToken() async {
    if (_currentToken == null) return;
    try {
      await ApiClient.instance.dio.delete(
        ApiEndpoints.deviceTokens,
        queryParameters: {'token': _currentToken},
      );
      debugPrint('[FCM] Token unregistered');
    } catch (e) {
      debugPrint('[FCM] Failed to unregister token: $e');
    } finally {
      _currentToken = null;
    }
  }

  Future<void> _registerTokenWithBackend(String token) async {
    try {
      await ApiClient.instance.dio.post(
        ApiEndpoints.deviceTokens,
        data: {
          'token': token,
          'platform': Platform.isIOS ? 1 : 0, // iOS = 1, Android = 0
          'deviceName': Platform.isIOS ? 'iOS Device' : 'Android Device',
        },
      );
      _currentToken = token;
      debugPrint('[FCM] Token registered');
    } catch (e) {
      debugPrint('[FCM] Failed to register token: $e');
    }
  }

  // ── Notification Display ──────────────────────────────────
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      _buildNotificationDetails(),
      payload: jsonEncode(message.data),
    );
  }

  NotificationDetails _buildNotificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        // Small icon shown in the status bar (monochrome)
        icon: _appIcon,
        // Large icon shown on the right side of the notification (full color)
        largeIcon: const DrawableResourceAndroidBitmap(_appIcon),
        // Accent color applied to the small icon and notification
        color: kPrimary,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  // ── Notification Tap Handlers ─────────────────────────────
  void _handleNotificationOpen(RemoteMessage message) {
    _navigateFromNotification(message.data);
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _navigateFromNotification(data);
    } catch (_) {
      Get.toNamed(AppRoutes.notifications);
    }
  }

  void _navigateFromNotification(Map<String, dynamic> data) {
    final taskId = data['taskId'] as String?;
    if (taskId != null && taskId.isNotEmpty) {
      _openTaskDetail(taskId);
    } else {
      Get.toNamed(AppRoutes.notifications);
    }
  }

  Future<void> _openTaskDetail(String taskId) async {
    TaskItemRepository? repo;
    try {
      repo = Get.find<TaskItemRepository>();
    } catch (_) {
      Get.toNamed(AppRoutes.notifications);
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final task = await repo.fetchTaskItemById(taskId);
      if (Get.isDialogOpen ?? false) Get.back();

      final context = Get.context;
      if (context == null) return;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final role = Get.find<AuthController>().role;

      if (role == UserRole.employee) {
        if (Get.isRegistered<EmployeeTaskController>()) {
          Get.find<EmployeeTaskController>().prepareTaskDetail(taskId);
        }
        Get.toNamed(
          AppRoutes.taskDetail,
          arguments: {'task': task, 'isDark': isDark, 'readOnly': false},
        );
      } else {
        await showTaskDetailSheet(
          context,
          isDark,
          task,
          fetchDetail: repo.fetchTaskItemById,
        );
      }
    } catch (_) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.toNamed(AppRoutes.notifications);
    }
  }
}
