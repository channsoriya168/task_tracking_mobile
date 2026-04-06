import 'package:json_annotation/json_annotation.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_comment.dart';

part 'task_comment_model.g.dart';

@JsonSerializable(createToJson: false)
class TaskCommentModel extends TaskComment {
  const TaskCommentModel({
    required super.id,
    required super.taskId,
    required super.employeeId,
    required super.employeeName,
    super.employeeProfileImageUrl,
    required super.content,
    super.parentCommentId,
    super.createdAt,
    super.updatedAt,
  });

  factory TaskCommentModel.fromJson(Map<String, dynamic> json) =>
      _$TaskCommentModelFromJson(json);
}