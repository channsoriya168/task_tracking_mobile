import 'package:flutter/material.dart';

class TaskPriority {
  final int id;
  final String name;

  const TaskPriority({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      other is TaskPriority && other.id == id;

  @override
  int get hashCode => id.hashCode;

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