class TaskComment {
  final String id;
  final String taskId;
  final String employeeId;
  final String employeeName;
  final String? employeeProfileImageUrl;
  final String content;
  final String? parentCommentId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TaskComment({
    required this.id,
    required this.taskId,
    required this.employeeId,
    required this.employeeName,
    this.employeeProfileImageUrl,
    required this.content,
    this.parentCommentId,
    this.createdAt,
    this.updatedAt,
  });
}