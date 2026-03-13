import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_priority.dart';

class TaskItem {
  final String id;
  final String title;
  final String? description;
  final String? groupId;
  final String? groupName;
  final String? labelId;
  final String? labelName;
  final String? labelColor;
  final String? assignedToId;
  final String? assignedToName;
  final String? createdById;
  final String? createdByEmployeeName;
  final TaskPriority priority;
  final TaskStatusLookup status;
  final DateTime? startDate;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<TaskStatusLookup> allowedTransitions;

  const TaskItem({
    required this.id,
    required this.title,
    this.description,
    this.groupId,
    this.groupName,
    this.labelId,
    this.labelName,
    this.labelColor,
    this.assignedToId,
    this.assignedToName,
    this.createdById,
    this.createdByEmployeeName,
    required this.priority,
    required this.status,
    this.startDate,
    this.dueDate,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.allowedTransitions = const [],
  });

  String get statusLabel => status.name;
  Color get statusColor => status.color;
  String get priorityLabel => priority.name;
  Color get priorityColor => priority.color;

  bool get isOverdue {
    if (dueDate == null) return false;
    final nameLower = status.name.toLowerCase();
    if (nameLower == 'complete' || nameLower == 'done') return false;
    return dueDate!.isBefore(DateTime.now());
  }

  TaskItem copyWith({
    String? title,
    String? description,
    String? groupId,
    String? groupName,
    String? labelId,
    TaskPriority? priority,
    TaskStatusLookup? status,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      labelId: labelId ?? this.labelId,
      labelName: labelName,
      labelColor: labelColor,
      assignedToId: assignedToId,
      assignedToName: assignedToName,
      createdById: createdById,
      createdByEmployeeName: createdByEmployeeName,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      startDate: startDate,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      completedAt: completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      allowedTransitions: allowedTransitions,
    );
  }
}