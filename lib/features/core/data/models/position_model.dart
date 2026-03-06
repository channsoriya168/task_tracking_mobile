import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/position.dart';

class PositionModel extends Position {
  PositionModel({required super.id, required super.name, required super.color});
}

// ── Mock Data ─────────────────────────────────────────────────
final List<PositionModel> listPosition = [
   PositionModel(id: 1, name: 'Engineering', color: Color(0xFF6C63FF)),
   PositionModel(id: 2, name: 'Design', color: Color(0xFF2ED573)),
   PositionModel(id: 3, name: 'Marketing', color: Color(0xFFFFA502)),
   PositionModel(id: 4, name: 'HR', color: Color(0xFFFF4757)),
];