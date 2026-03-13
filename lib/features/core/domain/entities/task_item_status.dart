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
      case 'assigned':
        return const Color(0xFFFFA502);
      case 'in progress':
        return const Color(0xFF6C63FF);
      case 'complete':
      case 'done':
        return const Color(0xFF2ED573);
      case 'fail':
      case 'failed':
        return const Color(0xFFFF4757);
      default:
        return const Color(0xFF6C63FF);
    }
  }
}
