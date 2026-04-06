// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'label_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LabelModel _$LabelModelFromJson(Map<String, dynamic> json) => LabelModel(
  id: json['id'] as String,
  name: json['name'] as String,
  color: json['color'] as String?,
  description: json['description'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$LabelModelToJson(LabelModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
      'description': instance.description,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
