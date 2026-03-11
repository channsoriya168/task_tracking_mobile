import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';

class TaskGroupModel extends TaskGroup {
  TaskGroupModel({
    required super.id,
    required super.name,
    super.color,
    super.description,
    super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory TaskGroupModel.fromJson(Map<String, dynamic> json) {
    return TaskGroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: _parseColor(json['color'] as String?),
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': _colorToHex(color),
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// For create/update request body (only mutable fields)
  Map<String, dynamic> toRequestJson() {
    return {
      'name': name,
      if (color != null) 'color': _colorToHex(color),
      if (description != null) 'description': description,
    };
  }

  static Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final sanitized = hex.replaceAll('#', '');
    final value = int.tryParse(
      sanitized.length == 6 ? 'FF$sanitized' : sanitized,
      radix: 16,
    );
    return value != null ? Color(value) : null;
  }

  static String? _colorToHex(Color? color) {
    if (color == null) return null;
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
