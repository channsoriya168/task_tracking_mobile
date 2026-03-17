import 'package:task_tracking_mobile/features/core/domain/entities/task_member.dart';

class TaskMemberModel extends TaskMember {
  const TaskMemberModel({
    required super.id,
    required super.taskItemId,
    required super.employeeId,
    required super.employeeName,
    super.employeeProfileImageUrl,
    super.addedById,
    super.addedByName,
    super.assignedAt,
  });

  factory TaskMemberModel.fromJson(Map<String, dynamic> json) {
    return TaskMemberModel(
      id: json['id'] as String,
      taskItemId: json['taskItemId'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String? ?? '',
      employeeProfileImageUrl: json['employeeProfileImageUrl'] as String?,
      addedById: json['addedById'] as String?,
      addedByName: json['addedByName'] as String?,
      assignedAt: json['assignedAt'] != null
          ? DateTime.tryParse(json['assignedAt'] as String)
          : null,
    );
  }
}
