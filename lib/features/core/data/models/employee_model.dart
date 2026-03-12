import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';

class EmployeeModel extends Employee {
  const EmployeeModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.phone,
    required super.isActive,
    super.profileImageUrl,
    super.placeOfBirth,
    super.dateOfBirth,
    required super.createdAt,
    super.updatedAt,
    required super.taskGroups,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final groupsJson = json['taskGroups'] as List<dynamic>? ?? [];
    final taskGroups = groupsJson.map((g) {
      return EmployeeTaskGroup(
        groupId: g['groupId'] as String,
        groupName: g['groupName'] as String,
        groupColor: _hexToColor(g['groupColor'] as String? ?? '#3B82F6'),
        role: _extractRole(g['role']),
        joinedAt: DateTime.parse(g['joinedAt'] as String),
      );
    }).toList();

    return EmployeeModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      profileImageUrl: json['profileImageUrl'] as String?,
      placeOfBirth: json['placeOfBirth'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      taskGroups: taskGroups,
    );
  }

  static int _extractRole(dynamic value) {
    if (value is int) return value;
    if (value is Map) return value['id'] as int? ?? 0;
    return 0;
  }

  static Color _hexToColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}
