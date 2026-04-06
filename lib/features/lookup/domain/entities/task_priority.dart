import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/features/lookup/domain/entities/lookup_item.dart';

class TaskPriority extends LookupItem {
  const TaskPriority({required super.id, required super.name});

  @override
  bool operator ==(Object other) => other is TaskPriority && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  Color get color => switch (name.toLowerCase()) {
    'critical' => const Color(0xFF9B0000),
    'high'     => const Color(0xFFFF4757),
    'medium'   => const Color(0xFFFFA502),
    'low'      => const Color(0xFF2ED573),
    _          => const Color(0xFF6C63FF),
  };
}
