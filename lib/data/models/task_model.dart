import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

enum TaskStatus { todo, inProgress, done, fail }

enum TaskPriority { high, medium, low }

class TaskModel {
  final String id;
  String title;
  String description;
  TaskStatus status;
  DateTime? dueDate;
  String category;
  TaskPriority priority;
  final DateTime createdAt;
  String? acceptedBy;
  String? acceptedByAvatar;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.status = TaskStatus.todo,
    this.dueDate,
    this.category = 'General',
    this.priority = TaskPriority.medium,
    DateTime? createdAt,
    this.acceptedBy,
    this.acceptedByAvatar,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.done) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  String get statusLabel {
    switch (status) {
      case TaskStatus.todo:       return 'Pending';
      case TaskStatus.inProgress: return 'In Progress';
      case TaskStatus.done:       return 'Complete';
      case TaskStatus.fail:       return 'Fail';
    }
  }

  Color get statusColor {
    switch (status) {
      case TaskStatus.todo:       return const Color(0xFFFFA502);
      case TaskStatus.inProgress: return kPrimary;
      case TaskStatus.done:       return kLowPriority;
      case TaskStatus.fail:       return kHighPriority;
    }
  }

  Color get priorityColor {
    switch (priority) {
      case TaskPriority.high:   return kHighPriority;
      case TaskPriority.medium: return kMediumPriority;
      case TaskPriority.low:    return kLowPriority;
    }
  }

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.high:   return 'High';
      case TaskPriority.medium: return 'Medium';
      case TaskPriority.low:    return 'Low';
    }
  }

  TaskModel copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? category,
    TaskPriority? priority,
    String? acceptedBy,
    bool clearAcceptedBy = false,
    String? acceptedByAvatar,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      acceptedBy: clearAcceptedBy ? null : (acceptedBy ?? this.acceptedBy),
      acceptedByAvatar: acceptedByAvatar ?? this.acceptedByAvatar,
    );
  }
}