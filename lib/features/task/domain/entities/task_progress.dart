class TaskProgress {
  final String id;
  final String taskId;
  final String employeeId;
  final String employeeName;
  final String? employeeProfileImageUrl;
  final int? status;
  final String? notes;
  final int progressPercentage;
  final DateTime? loggedAt;
  final double? hoursWorked;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TaskProgress({
    required this.id,
    required this.taskId,
    required this.employeeId,
    required this.employeeName,
    this.employeeProfileImageUrl,
    this.status,
    this.notes,
    required this.progressPercentage,
    this.loggedAt,
    this.hoursWorked,
    this.createdAt,
    this.updatedAt,
  });
}