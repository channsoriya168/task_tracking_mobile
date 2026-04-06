import 'package:json_annotation/json_annotation.dart';
import 'package:task_tracking_mobile/features/core/data/models/json_converters.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/group.dart';

part 'group_model.g.dart';

@JsonSerializable()
@ColorConverter()
class GroupModel extends Group {
  GroupModel({
    required super.id,
    required super.name,
    super.color,
    super.description,
    @JsonKey(defaultValue: true) super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$GroupModelToJson(this);

  /// Subset of fields sent in create/update requests.
  Map<String, dynamic> toRequestJson() => {
        'name': name,
        if (color != null) 'color': const ColorConverter().toJson(color),
        if (description != null) 'description': description,
      };
}
