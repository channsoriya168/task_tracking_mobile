import 'package:json_annotation/json_annotation.dart';
import 'package:task_tracking_mobile/features/label/domain/entities/label.dart';

part 'label_model.g.dart';

@JsonSerializable()
class LabelModel extends Label {
  LabelModel({
    required super.id,
    required super.name,
    super.color,
    super.description,
    @JsonKey(defaultValue: true) super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory LabelModel.fromJson(Map<String, dynamic> json) =>
      _$LabelModelFromJson(json);

  Map<String, dynamic> toJson() => _$LabelModelToJson(this);

  /// Subset of fields sent in create/update requests.
  Map<String, dynamic> toRequestJson() => {
    'name': name,
    if (description != null && description!.isNotEmpty)
      'description': description,
  };
}
