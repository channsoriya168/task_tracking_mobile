import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/lookup/domain/entities/lookup_item.dart';

class TaskStatusLookup extends LookupItem {
  final List<TaskStatusLookup> allowedTransitions;

  const TaskStatusLookup({
    required super.id,
    required super.name,
    this.allowedTransitions = const [],
  });

  String get localizedName => switch (name.toLowerCase()) {
    'pending' => 'status_pending'.tr,
    'assigned' => 'status_assigned'.tr,
    'inprogress' => 'status_inprogress'.tr,
    'inreview' || 'inview' => 'status_inreview'.tr,
    'completed' || 'complete' => 'status_completed'.tr,
    'cancelled' || 'cancel' => 'status_cancelled'.tr,
    'onhold' => 'status_onhold'.tr,
    _ => name,
  };

  @override
  Color get color => switch (name.toLowerCase()) {
    'pending' => const Color(0xFFFFA502),
    'assigned' => const Color(0xFF6C63FF),
    'inprogress' => const Color(0xFF3B82F6),
    'inreview' => const Color(0xFF06B6D4),
    'completed' => const Color(0xFF2ED573),
    'cancelled' => const Color(0xFFFF4757),
    'onhold' => const Color(0xFFFFB300),
    _ => const Color(0xFF6C63FF),
  };
}
