import 'package:task_tracking_mobile/features/notification/domain/entities/notification_entity.dart';

abstract interface class NotificationRepository {
  Future<List<NotificationEntity>> getMyNotifications();
  Future<int> getUnreadCount();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> delete(String notificationId);
}
