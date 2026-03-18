import 'package:task_tracking_mobile/features/core/domain/entities/task_comment.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_member.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_progress.dart';

abstract interface class TaskItemRepository {
  Future<List<TaskItem>> fetchTaskItems({
    String? search,
    int? statusId,
    String? groupId,
    DateTime? SelectedDate,
  });
  Future<TaskItem> fetchTaskItemById(String id);
  Future<void> addTaskItem(TaskItem taskItem);
  Future<void> updateTaskItem(TaskItem taskItem);
  Future<void> deleteTaskItem(TaskItem taskItem);
  Future<void> assignTask(String id, String assignedToId);
  Future<void> updateTaskStatus(String id, int status);
  Future<List<TaskMember>> fetchTaskMembers(String taskItemId);
  Future<void> addTaskMember(String taskItemId, String employeeId);
  Future<void> removeTaskMember(String taskItemId, String memberId);

  // ── Comments ─────────────────────────────────────────────────────────────
  Future<List<TaskComment>> fetchTaskComments(String taskItemId);

  // ── Progress ────────────────────────────────────────────────────────────
  Future<List<TaskProgress>> fetchTaskProgresses(String taskItemId);
  Future<void> createTaskProgress(
    String taskItemId, {
    required int progressPercentage,
    required DateTime loggedAt,
    String? notes,
    double? hoursWorked,
    int? status,
  });
  Future<void> updateTaskProgress(
    String taskItemId,
    String progressId, {
    required int progressPercentage,
    required DateTime loggedAt,
    required String notes,
    double? hoursWorked,
    int? status,
  });
  Future<void> deleteTaskProgress(String taskItemId, String progressId);
}
