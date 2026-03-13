import 'package:task_tracking_mobile/features/core/domain/entities/task_priority.dart';

class TaskPriorityModel extends TaskPriority {
  const TaskPriorityModel({required super.id, required super.name});
  factory TaskPriorityModel.fromJson(Map<String, dynamic> json) {
    return TaskPriorityModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
