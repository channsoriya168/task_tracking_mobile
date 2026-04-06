import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/routes/app_routes.dart';
import 'package:task_tracking_mobile/core/network/api_client.dart';
import 'package:task_tracking_mobile/core/network/api_endpoints.dart';

class PushNotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _currentToken;

  // ── Notification channel (Android) ─────────────────────────
  static const _channel = AndroidNotificationChannel(
    'task_tracking_notifications',
    'Task Notifications',
    description: 'Notifications for task updates, comments, and reminders.',
    importance: Importance.high,
  );

  // ── Initialization ────────────────────────────────────────
  Future<PushNotificationService> init() async {
    // Create the Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // iOS foreground presentation options
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Initialize flutter_local_notifications
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Listen for notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

    // Check if app was opened from a terminated notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      // Delay slightly to let the app initialize navigation
      Future.delayed(const Duration(seconds: 1), () {
        _handleNotificationOpen(initialMessage);
      });
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      if (_currentToken != null) {
        _registerTokenWithBackend(newToken);
      }
    });

    return this;
  }

  // ── Permission Request ────────────────────────────────────
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  // ── Token Registration ────────────────────────────────────
  /// Call after successful login to register FCM token with backend.
  Future<void> registerToken() async {
    final granted = await requestPermission();
    if (!granted) {
      debugPrint('Push notification permission not granted');
      return;
    }

    final token = await _messaging.getToken();
    if (token == null) {
      debugPrint('Failed to get FCM token');
      return;
    }

    _currentToken = token;
    await _registerTokenWithBackend(token);
  }

  /// Call before logout to unregister FCM token from backend.
  Future<void> unregisterToken() async {
    if (_currentToken != null) {
      try {
        await ApiClient.instance.dio.delete(
          ApiEndpoints.deviceTokens,
          queryParameters: {'token': _currentToken},
        );
        debugPrint('FCM token unregistered from backend');
      } catch (e) {
        debugPrint('Failed to unregister FCM token: $e');
      }
    }
    _currentToken = null;
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
      debugPrint('FCM token registered with backend');
    } catch (e) {
      debugPrint('Failed to register FCM token: $e');
    }
  }

  // ── Foreground Message Handler ────────────────────────────
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  // ── Notification Tap Handlers ─────────────────────────────
  void _handleNotificationOpen(RemoteMessage message) {
    final data = message.data;
    _navigateFromNotification(data);
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _navigateFromNotification(data);
    } catch (_) {
      // Fallback: just go to notifications page
      Get.toNamed(AppRoutes.notifications);
    }
  }

  void _navigateFromNotification(Map<String, dynamic> data) {
    // Navigate to notifications list — the user can see details there
    Get.toNamed(AppRoutes.notifications);
  }
}
