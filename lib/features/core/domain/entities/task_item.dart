import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

enum TaskItemPriority {
  high(1),
  medium(2),
  low(3);

  const TaskItemPriority(this.value);
  final int value;

  static TaskItemPriority fromValue(int value) {
    return TaskItemPriority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaskItemPriority.medium,
    );
  }
}

enum TaskItemStatus {
  todo(1),
  inProgress(2),
  done(3),
  fail(4);

  const TaskItemStatus(this.value);
  final int value;

  static TaskItemStatus fromValue(int value) {
    return TaskItemStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaskItemStatus.todo,
    );
  }
}

class TaskItem {
  final String id;
  final String title;
  final String? description;
  final String? groupId;
  final String? groupName;
  final String labelId;
  final String? labelName;
  final String? labelColor;
  final String? assignedToId;
  final String? assignedToName;
  final String createdById;
  final String? createdByEmployeeName;
  final TaskItemPriority priority;
  final TaskItemStatus status;
  final DateTime? startDate;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TaskItem({
    required this.id,
    required this.title,
    this.description,
    this.groupId,
    this.groupName,
    required this.labelId,
    this.labelName,
    this.labelColor,
    this.assignedToId,
    this.assignedToName,
    required this.createdById,
    this.createdByEmployeeName,
    required this.priority,
    required this.status,
    this.startDate,
    this.dueDate,
    this.completedAt,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isOverdue {
    if (dueDate == null || status == TaskItemStatus.done) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  String get statusLabel {
    switch (status) {
      case TaskItemStatus.todo:
        return 'Pending';
      case TaskItemStatus.inProgress:
        return 'In Progress';
      case TaskItemStatus.done:
        return 'Complete';
      case TaskItemStatus.fail:
        return 'Fail';
    }
  }

  Color get statusColor => kStatusColors[statusLabel] ?? kPrimary;

  String get priorityLabel {
    switch (priority) {
      case TaskItemPriority.high:
        return 'High';
      case TaskItemPriority.medium:
        return 'Medium';
      case TaskItemPriority.low:
        return 'Low';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case TaskItemPriority.high:
        return kHighPriority;
      case TaskItemPriority.medium:
        return kMediumPriority;
      case TaskItemPriority.low:
        return kLowPriority;
    }
  }

  TaskItem copyWith({
    String? title,
    String? description,
    String? groupId,
    String? groupName,
    String? labelId,
    String? labelName,
    String? labelColor,
    String? assignedToId,
    String? assignedToName,
    TaskItemPriority? priority,
    TaskItemStatus? status,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? completedAt,
    DateTime? updatedAt,
    bool clearDueDate = false,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      labelId: labelId ?? this.labelId,
      labelName: labelName ?? this.labelName,
      labelColor: labelColor ?? this.labelColor,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedToName: assignedToName ?? this.assignedToName,
      createdById: createdById,
      createdByEmployeeName: createdByEmployeeName,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
