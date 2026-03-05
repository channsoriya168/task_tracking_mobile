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

// ── Mock Data ─────────────────────────────────────────────────

final List<Position> kMockPositions = [
  const Position(id: 'p1', name: 'Engineering', color: Color(0xFF6C63FF)),
  const Position(id: 'p2', name: 'Design', color: Color(0xFF2ED573)),
  const Position(id: 'p3', name: 'Marketing', color: Color(0xFFFFA502)),
  const Position(id: 'p4', name: 'HR', color: Color(0xFFFF4757)),
];