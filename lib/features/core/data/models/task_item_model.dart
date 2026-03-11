import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';

class TaskItemModel extends TaskItem {
  TaskItemModel({
    required super.id,
    required super.title,
    super.description,
    super.groupId,
    super.groupName,
    required super.labelId,
    super.labelName,
    super.labelColor,
    super.assignedToId,
    super.assignedToName,
    required super.createdById,
    super.createdByEmployeeName,
    required super.priority,
    required super.status,
    super.startDate,
    super.dueDate,
    super.completedAt,
    required super.createdAt,
    super.updatedAt,
  });

  factory TaskItemModel.fromJson(Map<String, dynamic> json) {
    return TaskItemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      groupId: json['groupId'] as String?,
      groupName: json['groupName'] as String?,
      labelId: json['labelId'] as String,
      labelName: json['labelName'] as String?,
      labelColor: json['labelColor'] as String?,
      assignedToId: json['assignedToId'] as String?,
      assignedToName: json['assignedToName'] as String?,
      createdById: json['createdById'] as String,
      createdByEmployeeName: json['createdByEmployeeName'] as String?,
      priority: TaskItemPriority.fromValue(json['priority'] as int),
      status: TaskItemStatus.fromValue(json['status'] as int),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'groupId': groupId,
      'groupName': groupName,
      'labelId': labelId,
      'labelName': labelName,
      'labelColor': labelColor,
      'assignedToId': assignedToId,
      'assignedToName': assignedToName,
      'createdById': createdById,
      'createdByEmployeeName': createdByEmployeeName,
      'priority': priority.value,
      'status': status.value,
      'startDate': startDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// For POST /api/v1/task-items request body
  Map<String, dynamic> toRequestJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      if (groupId != null) 'groupId': groupId,
      'labelId': labelId,
      if (assignedToId != null) 'assignedToId': assignedToId,
      'priority': priority.value,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
    };
  }
}
