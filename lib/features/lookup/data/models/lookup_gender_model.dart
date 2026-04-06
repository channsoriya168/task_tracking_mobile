import 'package:json_annotation/json_annotation.dart';
import 'package:task_tracking_mobile/features/lookup/domain/entities/lookup_gender.dart';

part 'lookup_gender_model.g.dart';

String _idFromJson(dynamic value) => value.toString();

@JsonSerializable()
class LookupGenderModel extends LookupGender {
  LookupGenderModel({required super.id, required super.name});

  factory LookupGenderModel.fromJson(Map<String, dynamic> json) =>
      _$LookupGenderModelFromJson(json);

  Map<String, dynamic> toJson() => _$LookupGenderModelToJson(this);

  @override
  @JsonKey(fromJson: _idFromJson)
  String get id => super.id;
}
