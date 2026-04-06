import 'package:dio/dio.dart';
import 'package:task_tracking_mobile/core/utils/dio_error_mapper.dart';
import 'package:task_tracking_mobile/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:task_tracking_mobile/features/notification/domain/entities/notification_entity.dart';
import 'package:task_tracking_mobile/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource _remote;

  NotificationRepositoryImpl(this._remote);

  @override
  Future<List<NotificationEntity>> getMyNotifications() async {
    try {
      return await _remote.getMyNotifications();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      return await _remote.getUnreadCount();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _remote.markAsRead(notificationId);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _remote.markAllAsRead();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> delete(String notificationId) async {
    try {
      await _remote.delete(notificationId);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
