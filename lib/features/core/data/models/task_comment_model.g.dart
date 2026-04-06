// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskCommentModel _$TaskCommentModelFromJson(Map<String, dynamic> json) =>
    TaskCommentModel(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      employeeProfileImageUrl: json['employeeProfileImageUrl'] as String?,
      content: json['content'] as String,
      parentCommentId: json['parentCommentId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );
