import 'package:task_tracking_mobile/features/manager/data/models/position.dart';

class Task {
  final int id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final Position position_id;
  Task({
    required this.id,
    required this.title,
    required this.description,
    this.dueDate,
    required this.position_id,
  });
}
