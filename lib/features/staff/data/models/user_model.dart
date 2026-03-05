import 'package:flutter/material.dart';

enum UserRole { admin, manager, staff }

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

  String get roleLabel {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.staff:
        return 'Staff';
    }
  }

  Color get roleColor {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFF6C63FF);
      case UserRole.manager:
        return const Color(0xFFFFA502);
      case UserRole.staff:
        return const Color(0xFF2ED573);
    }
  }

  IconData get roleIcon {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
      case UserRole.manager:
        return Icons.analytics_rounded;
      case UserRole.staff:
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
    role: UserRole.staff,
    avatarLetter: 'M',
  ),
  UserModel(
    id: 'staff2',
    name: 'Emma Davis',
    email: 'emma@company.com',
    role: UserRole.staff,
    avatarLetter: 'E',
  ),
  UserModel(
    id: 'staff3',
    name: 'James Wilson',
    email: 'james@company.com',
    role: UserRole.staff,
    avatarLetter: 'J',
  ),
];
