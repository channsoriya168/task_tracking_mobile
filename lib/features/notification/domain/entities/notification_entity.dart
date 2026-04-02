/// Notification types matching the backend NotificationType enum.
enum NotificationType {
  taskStatusChanged(1),
  taskCommented(2),
  taskDueDateApproaching(3),
  taskAddedToGroup(4),
  taskCompleted(5);

  final int value;
  const NotificationType(this.value);

  static NotificationType fromValue(int value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.taskStatusChanged,
    );
  }
}

class NotificationEntity {
  final String id;
  final String recipientId;
  final String? taskId;
  final NotificationType type;
  final String typeName;
  final String title;
  final String? message;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.recipientId,
    this.taskId,
    required this.type,
    required this.typeName,
    required this.title,
    this.message,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });
}
