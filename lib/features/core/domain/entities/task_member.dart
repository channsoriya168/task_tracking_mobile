class TaskMember {
  final String id;
  final String taskItemId;
  final String employeeId;
  final String employeeName;
  final String? employeeProfileImageUrl;
  final String? addedById;
  final String? addedByName;
  final DateTime? assignedAt;

  const TaskMember({
    required this.id,
    required this.taskItemId,
    required this.employeeId,
    required this.employeeName,
    this.employeeProfileImageUrl,
    this.addedById,
    this.addedByName,
    this.assignedAt,
  });
}
