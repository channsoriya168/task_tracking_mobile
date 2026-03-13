import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/lookup_item.dart';

class TaskStatusLookup extends LookupItem {
  final List<TaskStatusLookup> allowedTransitions;

  const TaskStatusLookup({
    required super.id,
    required super.name,
    this.allowedTransitions = const [],
  });

  @override
  Color get color {
    switch (name.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFA502);
      case 'assigned':
        return const Color(0xFF6C63FF);
      case 'inprogress':
        return const Color(0xFF3B82F6);
      case 'inreview':
        return const Color(0xFF06B6D4);
      case 'completed':
        return const Color(0xFF2ED573);
      case 'cancelled':
        return const Color(0xFFFF4757);
      case 'onhold':
        return const Color(0xFFFFB300);
      default:
        return const Color(0xFF6C63FF);
    }
  }
}
