import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/features/core/data/models/lookup_item_model.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_priority.dart';

class TaskPriorityModel extends TaskPriority implements LookupItemModel {
  const TaskPriorityModel({required super.id, required super.name});

  factory TaskPriorityModel.fromJson(Map<String, dynamic> json) {
    return TaskPriorityModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => LookupItemModel.toBaseJson(this);

  @override
  Color get color => super.color;
}
