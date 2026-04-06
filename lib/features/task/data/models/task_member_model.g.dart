// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskMemberModel _$TaskMemberModelFromJson(Map<String, dynamic> json) =>
    TaskMemberModel(
      id: json['id'] as String,
      taskItemId: json['taskItemId'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      employeeProfileImageUrl: json['employeeProfileImageUrl'] as String?,
      addedById: json['addedById'] as String?,
      addedByName: json['addedByName'] as String?,
      assignedAt: json['assignedAt'] == null
          ? null
          : DateTime.parse(json['assignedAt'] as String),
    );
