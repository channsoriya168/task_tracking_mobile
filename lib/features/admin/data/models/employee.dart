import 'package:flutter/material.dart';

class Position {
  final String id;
  final String name;
  final Color color;

  const Position({required this.id, required this.name, required this.color});

  Position copyWith({String? id, String? name, Color? color}) {
    return Position(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }
}

class Employee {
  final String id;
  final String name;
  final String email;
  final String positionId;
  final String? imagePath;
  final DateTime? dateOfBirth;
  final String? placeOfBirth;
  final String? phone;
  final String? userId;

  const Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.positionId,
    this.imagePath,
    this.dateOfBirth,
    this.placeOfBirth,
    this.phone,
    this.userId,
  });

  Employee copyWith({
    String? id,
    String? name,
    String? email,
    String? positionId,
    String? imagePath,
    DateTime? dateOfBirth,
    String? placeOfBirth,
    String? phone,
    String? userId,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      positionId: positionId ?? this.positionId,
      imagePath: imagePath ?? this.imagePath,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      phone: phone ?? this.phone,
      userId: userId ?? this.userId,
    );
  }
}

// ── Mock Data ─────────────────────────────────────────────────

final List<Position> kMockPositions = [
  const Position(id: 'p1', name: 'Engineering', color: Color(0xFF6C63FF)),
  const Position(id: 'p2', name: 'Design', color: Color(0xFF2ED573)),
  const Position(id: 'p3', name: 'Marketing', color: Color(0xFFFFA502)),
  const Position(id: 'p4', name: 'HR', color: Color(0xFFFF4757)),
];

final List<Employee> kMockEmployees = [
  const Employee(
    id: 'e1',
    name: 'Alice Johnson',
    email: 'alice@company.com',
    positionId: 'p1',
  ),
  const Employee(
    id: 'e2',
    name: 'Bob Smith',
    email: 'bob@company.com',
    positionId: 'p1',
  ),
  const Employee(
    id: 'e3',
    name: 'Charlie Brown',
    email: 'charlie@company.com',
    positionId: 'p1',
  ),
  const Employee(
    id: 'e4',
    name: 'Diana Prince',
    email: 'diana@company.com',
    positionId: 'p2',
  ),
  const Employee(
    id: 'e5',
    name: 'Eve Davis',
    email: 'eve@company.com',
    positionId: 'p2',
  ),
  const Employee(
    id: 'e6',
    name: 'Frank Miller',
    email: 'frank@company.com',
    positionId: 'p3',
  ),
  const Employee(
    id: 'e7',
    name: 'Grace Lee',
    email: 'grace@company.com',
    positionId: 'p3',
  ),
  const Employee(
    id: 'e8',
    name: 'Henry Wilson',
    email: 'henry@company.com',
    positionId: 'p4',
  ),
  const Employee(
    id: 'e9',
    name: 'Isabella Chen',
    email: 'isabella@company.com',
    positionId: 'p4',
  ),
  const Employee(
    id: 'e10',
    name: 'James Taylor',
    email: 'james@company.com',
    positionId: 'p1',
  ),
];
