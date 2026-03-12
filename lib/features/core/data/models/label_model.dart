import 'package:task_tracking_mobile/features/core/domain/entities/label.dart';

class LabelModel extends Label {
  LabelModel({
    required super.id,
    required super.name,
    super.color,
    super.description,
    super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory LabelModel.fromJson(Map<String, dynamic> json) {
    return LabelModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String?,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'name': name,
      if (description != null && description!.isNotEmpty)
        'description': description,
    };
  }
}
