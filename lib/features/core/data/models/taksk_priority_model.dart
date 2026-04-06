import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:task_tracking_mobile/features/core/data/models/lookup_item_model.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_priority.dart';

part 'taksk_priority_model.g.dart';

@JsonSerializable(createToJson: false)
class TaskPriorityModel extends TaskPriority implements LookupItemModel {
  const TaskPriorityModel({required super.id, required super.name});

  factory TaskPriorityModel.fromJson(Map<String, dynamic> json) =>
      _$TaskPriorityModelFromJson(json);

  Map<String, dynamic> toJson() => LookupItemModel.toBaseJson(this);

  @override
  Color get color => super.color;
}
