import 'package:flutter/material.dart';

class EmployeeGroup {
  final String groupId;
  final String groupName;
  final Color groupColor;
  final int role; // 0 = member, 1 = lead
  final DateTime joinedAt;

  const EmployeeGroup({
    required this.groupId,
    required this.groupName,
    required this.groupColor,
    required this.role,
    required this.joinedAt,
  });
}

class Employee {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final bool isActive;
  final String? role;
  final String? profileImageUrl;
  final String? placeOfBirth;
  final DateTime? dateOfBirth;
  final String? genderId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<EmployeeGroup> groups;

  const Employee({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.isActive,
    this.role,
    this.profileImageUrl,
    this.placeOfBirth,
    this.dateOfBirth,
    this.genderId,
    required this.createdAt,
    this.updatedAt,
    required this.groups,
  });
}
