import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:task_tracking_mobile/app/services/api_client.dart';
import 'package:task_tracking_mobile/app/utils/api_endpoints.dart';
import 'package:task_tracking_mobile/features/notification/data/models/notification_model.dart';

class NotificationRemoteDatasource {
  final Dio _dio;

  NotificationRemoteDatasource() : _dio = ApiClient.instance.dio;

  @visibleForTesting
  NotificationRemoteDatasource.withDio(this._dio);

  Future<List<NotificationModel>> getMyNotifications() async {
    final response = await _dio.get(ApiEndpoints.notifications);
    final data = response.data as List<dynamic>;
    return data
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get(ApiEndpoints.notificationsUnreadCount);
    final data = response.data as Map<String, dynamic>;
    return data['count'] as int? ?? 0;
  }

  Future<void> markAsRead(String notificationId) async {
    await _dio.put(ApiEndpoints.notificationMarkRead(notificationId));
  }

  Future<void> markAllAsRead() async {
    await _dio.put(ApiEndpoints.notificationsMarkAllRead);
  }

  Future<void> delete(String notificationId) async {
    await _dio.delete(ApiEndpoints.notificationById(notificationId));
  }
}
