import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

enum TaskPriority { low, medium, high }

enum TaskStatus { todo, inProgress, done }

class TaskModel {
  final String id;
  String title;
  String description;
  TaskPriority priority;
  TaskStatus status;
  DateTime? dueDate;
  String category;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.dueDate,
    this.category = 'General',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.done) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  Color get priorityColor {
    switch (priority) {
      case TaskPriority.high:
        return kHighPriority;
      case TaskPriority.medium:
        return kMediumPriority;
      case TaskPriority.low:
        return kLowPriority;
    }
  }

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  String get statusLabel {
    switch (status) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }

  Color get statusColor {
    switch (status) {
      case TaskStatus.todo:
        return kTextMuted;
      case TaskStatus.inProgress:
        return kPrimary;
      case TaskStatus.done:
        return kLowPriority;
    }
  }

  TaskModel copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? category,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      category: category ?? this.category,
      createdAt: createdAt,
    );
  }
}
