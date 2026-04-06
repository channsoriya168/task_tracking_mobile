import 'package:task_tracking_mobile/features/lookup/data/models/lookup_item_model.dart';
import 'package:task_tracking_mobile/features/lookup/domain/entities/task_item_status.dart';

class TaskItemStatusModel extends TaskStatusLookup implements LookupItemModel {
  const TaskItemStatusModel({
    required super.id,
    required super.name,
    super.allowedTransitions = const [],
  });

  factory TaskItemStatusModel.fromJson(Map<String, dynamic> json) {
    final transitions = (json['allowedTransitions'] as List<dynamic>? ?? [])
        .map((e) => TaskItemStatusModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return TaskItemStatusModel(
      id: json['id'] as int,
      name: json['name'] as String,
      allowedTransitions: transitions,
    );
  }

  Map<String, dynamic> toJson() => LookupItemModel.toBaseJson(this);
}
