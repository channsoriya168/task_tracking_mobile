import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/lookup_item.dart';

class TaskPriority extends LookupItem {
  const TaskPriority({required super.id, required super.name});

  @override
  bool operator ==(Object other) => other is TaskPriority && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  Color get color {
    switch (name.toLowerCase()) {
      case 'critical':
        return const Color(0xFF9B0000);
      case 'high':
        return const Color(0xFFFF4757);
      case 'medium':
        return const Color(0xFFFFA502);
      case 'low':
        return const Color(0xFF2ED573);
      default:
        return const Color(0xFF6C63FF);
    }
  }
}
