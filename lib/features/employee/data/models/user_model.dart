import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/enums/user_role.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String avatarLetter;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatarLetter,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? json['fullName'] as String? ?? '';
    final roleStr =
        (json['role'] as String? ?? json['roleName'] as String? ?? '')
            .toLowerCase();
    final role = UserRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => UserRole.employee,
    );
    return UserModel(
      id: json['id']?.toString() ?? json['userId']?.toString() ?? '',
      name: name,
      email: json['email'] as String? ?? '',
      role: role,
      avatarLetter: name.isNotEmpty ? name[0].toUpperCase() : '?',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'avatarLetter': avatarLetter,
      };

  String get roleLabel {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.employee:
        return 'Employee';
    }
  }

  Color get roleColor {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFF6C63FF);
      case UserRole.manager:
        return const Color(0xFFFFA502);
      case UserRole.employee:
        return const Color(0xFF2ED573);
    }
  }

  IconData get roleIcon {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
      case UserRole.manager:
        return Icons.analytics_rounded;
      case UserRole.employee:
        return Icons.work_rounded;
    }
  }
}

const List<UserModel> kSampleUsers = [
  UserModel(
    id: 'admin1',
    name: 'Alex Johnson',
    email: 'alex@company.com',
    role: UserRole.admin,
    avatarLetter: 'A',
  ),
  UserModel(
    id: 'manager1',
    name: 'Sarah Lee',
    email: 'sarah@company.com',
    role: UserRole.manager,
    avatarLetter: 'S',
  ),
  UserModel(
    id: 'staff1',
    name: 'Mike Chen',
    email: 'mike@company.com',
    role: UserRole.employee,
    avatarLetter: 'M',
  ),
  UserModel(
    id: 'staff2',
    name: 'Emma Davis',
    email: 'emma@company.com',
    role: UserRole.employee,
    avatarLetter: 'E',
  ),
  UserModel(
    id: 'staff3',
    name: 'James Wilson',
    email: 'james@company.com',
    role: UserRole.employee,
    avatarLetter: 'J',
  ),
];
