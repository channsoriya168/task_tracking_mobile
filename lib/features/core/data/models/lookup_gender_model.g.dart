// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lookup_gender_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LookupGenderModel _$LookupGenderModelFromJson(Map<String, dynamic> json) =>
    LookupGenderModel(
      id: _idFromJson(json['id']),
      name: json['name'] as String,
    );

Map<String, dynamic> _$LookupGenderModelToJson(LookupGenderModel instance) =>
    <String, dynamic>{'name': instance.name, 'id': instance.id};
