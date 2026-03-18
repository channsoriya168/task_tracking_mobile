import 'package:task_tracking_mobile/features/core/domain/entities/task_comment.dart';

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

  factory TaskCommentModel.fromJson(Map<String, dynamic> json) {
    return TaskCommentModel(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String? ?? '',
      employeeProfileImageUrl: json['employeeProfileImageUrl'] as String?,
      content: json['content'] as String? ?? '',
      parentCommentId: json['parentCommentId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }
}
