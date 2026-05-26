import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/features/employee/domain/entities/employee.dart';

class EmployeeModel extends Employee {
  const EmployeeModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.phoneNumber,
    required super.isActive,
    super.role,
    super.profileImageUrl,
    super.placeOfBirth,
    super.dateOfBirth,
    super.genderId,
    required super.createdAt,
    super.updatedAt,
    required super.groups,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final groupsJson = json['groups'] as List<dynamic>? ?? [];
    final groups = groupsJson.where((g) => g['groupId'] != null).map((g) {
      return EmployeeGroup(
        groupId: g['groupId'] as String,
        groupName: g['groupName'] as String? ?? '',
        groupColor: _hexToColor(g['groupColor'] as String? ?? '#3B82F6'),
        role: _extractRole(g['role']),
        joinedAt: g['joinedAt'] != null
            ? DateTime.parse(g['joinedAt'] as String)
            : DateTime.now(),
      );
    }).toList();

    return EmployeeModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      role: json['role'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      placeOfBirth: json['placeOfBirth'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      groups: groups,
      genderId: _parseGenderId(json['gender']),
    );
  }

  static String? _parseGenderId(dynamic value) {
    if (value == null) return null;
    final n = value is int ? value : int.tryParse(value.toString());
    if (n == null || n == 0) return null;
    return n.toString();
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
