import 'package:task_tracking_mobile/features/task/domain/entities/task_progress.dart';

class TaskProgressModel extends TaskProgress {
  const TaskProgressModel({
    required super.id,
    required super.taskId,
    required super.employeeId,
    required super.employeeName,
    super.employeeProfileImageUrl,
    super.status,
    super.notes,
    required super.progressPercentage,
    super.loggedAt,
    super.hoursWorked,
    super.createdAt,
    super.updatedAt,
  });

  factory TaskProgressModel.fromJson(Map<String, dynamic> json) {
    return TaskProgressModel(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String? ?? '',
      employeeProfileImageUrl: json['employeeProfileImageUrl'] as String?,
      status: json['status'] is Map
          ? (json['status'] as Map)['id'] as int?
          : json['status'] as int?,
      notes: json['notes'] as String?,
      progressPercentage: (json['progressPercentage'] as num?)?.toInt() ?? 0,
      loggedAt: json['loggedAt'] != null
          ? DateTime.tryParse(json['loggedAt'] as String)
          : null,
      hoursWorked: (json['hoursWorked'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }
}

/// Body sent to POST /api/v1/task-items/{taskItemId}/progresses
class CreateProgressBody {
  final int progressPercentage;
  final DateTime loggedAt;
  final String? notes;
  final double? hoursWorked;
  final int? status;

  const CreateProgressBody({
    required this.progressPercentage,
    required this.loggedAt,
    this.notes,
    this.hoursWorked,
    this.status,
  });

  Map<String, dynamic> toJson() => {
    'progressPercentage': progressPercentage,
    'loggedAt': loggedAt.toUtc().toIso8601String(),
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    if (hoursWorked != null) 'hoursWorked': hoursWorked,
    if (status != null) 'status': status,
  };
}