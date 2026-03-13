import 'package:flutter/material.dart';

class TaskStatusLookup {
  final int id;
  final String name;
  final List<TaskStatusLookup> allowedTransitions;

  const TaskStatusLookup({
    required this.id,
    required this.name,
    this.allowedTransitions = const [],
  });

  Color get color {
    switch (name.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFA502);
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
