import 'package:task_tracking_mobile/features/notification/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.recipientId,
    super.taskId,
    required super.type,
    required super.typeName,
    required super.title,
    super.message,
    required super.isRead,
    super.readAt,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      recipientId: json['recipientId'] as String,
      taskId: json['taskId'] as String?,
      type: NotificationType.fromValue(json['type'] as int),
      typeName: json['typeName'] as String? ?? '',
      title: json['title'] as String,
      message: json['message'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
