import 'package:task_tracking_mobile/features/core/data/models/taksk_priority_model.dart';
import 'package:task_tracking_mobile/features/core/data/models/task_item_status_model.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';

class TaskItemModel extends TaskItem {
  const TaskItemModel({
    required super.id,
    required super.title,
    super.description,
    super.groupId,
    super.groupName,
    super.labelId,
    super.labelName,
    super.labelColor,
    super.assignedToId,
    super.assignedToName,
    super.createdById,
    super.createdByEmployeeName,
    required super.priority,
    required super.status,
    super.startDate,
    super.dueDate,
    super.completedAt,
    super.createdAt,
    super.updatedAt,
    super.allowedTransitions = const [],
  });

  factory TaskItemModel.fromJson(Map<String, dynamic> json) {
    return TaskItemModel(
      // UUID returned as string
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      groupId: json['groupId'] as String?,
      groupName: json['groupName'] as String?,
      labelId: json['labelId'] as String?,
      labelName: json['labelName'] as String?,
      // Hex color string e.g. "#805AD5"
      labelColor: json['labelColor'] as String?,
      assignedToId: json['assignedToId'] as String?,
      assignedToName: json['assignedToName'] as String?,
      createdById: json['createdById'] as String?,
      createdByEmployeeName: json['createdByEmployeeName'] as String?,
      // Priority: {id, name}
      priority: TaskPriorityModel.fromJson(
        json['priority'] as Map<String, dynamic>,
      ),
      // Status in task response: {id, name} only — no nested allowedTransitions
      status: TaskItemStatusModel.fromJson(
        json['status'] as Map<String, dynamic>,
      ),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      // Root-level allowedTransitions: [{id, name}, ...] — valid next statuses
      allowedTransitions:
          (json['allowedTransitions'] as List<dynamic>? ?? [])
              .map((e) => TaskItemStatusModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (groupId != null) 'groupId': groupId,
      if (labelId != null) 'labelId': labelId,
      if (assignedToId != null) 'assignedToId': assignedToId,
      'priority': priority.id,
      if (startDate != null) 'startDate': startDate!.toUtc().toIso8601String(),
      if (dueDate != null) 'dueDate': dueDate!.toUtc().toIso8601String(),
    };
  }
}