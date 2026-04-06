import 'package:json_annotation/json_annotation.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_member.dart';

part 'task_member_model.g.dart';

@JsonSerializable(createToJson: false)
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

  factory TaskMemberModel.fromJson(Map<String, dynamic> json) =>
      _$TaskMemberModelFromJson(json);
}