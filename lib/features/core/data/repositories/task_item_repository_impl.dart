import 'package:task_tracking_mobile/features/core/data/datasources/remote/task_item_remote_datasource.dart';
import 'package:task_tracking_mobile/features/core/data/models/task_item_model.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_comment.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_member.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_progress.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_item_repository.dart';

class TaskItemRepositoryImpl implements TaskItemRepository {
  final TaskItemRemoteDatasource _remote;

  TaskItemRepositoryImpl(this._remote);

  @override
  Future<List<TaskItem>> fetchTaskItems({
    String? search,
    int? statusId,
    String? groupId,
    DateTime? SelectedDate,
  }) => _remote.getAll(
    search: search,
    statusId: statusId,
    groupId: groupId,
    SelectedDate: SelectedDate,
  );

  @override
  Future<TaskItem> fetchTaskItemById(String id) => _remote.getById(id);

  @override
  Future<void> addTaskItem(TaskItem taskItem) =>
      _remote.create(taskItem as TaskItemModel);

  @override
  Future<void> updateTaskItem(TaskItem taskItem) =>
      _remote.update(taskItem.id, taskItem as TaskItemModel);

  @override
  Future<void> deleteTaskItem(TaskItem taskItem) => _remote.delete(taskItem.id);

  @override
  Future<void> assignTask(String id, String assignedToId) =>
      _remote.assignTask(id, assignedToId);

  @override
  Future<void> updateTaskStatus(String id, int status) =>
      _remote.updateStatus(id, status);

  @override
  Future<List<TaskMember>> fetchTaskMembers(String taskItemId) =>
      _remote.getTaskMembers(taskItemId);

  @override
  Future<void> addTaskMember(String taskItemId, String employeeId) =>
      _remote.addTaskMember(taskItemId, employeeId);

  @override
  Future<void> removeTaskMember(String taskItemId, String memberId) =>
      _remote.removeTaskMember(taskItemId, memberId);

  @override
  Future<List<TaskComment>> fetchTaskComments(String taskItemId) =>
      _remote.getTaskComments(taskItemId);

  @override
  Future<void> createTaskComment(
    String taskItemId, {
    required String content,
    String? parentCommentId,
  }) =>
      _remote.createTaskComment(
        taskItemId,
        content: content,
        parentCommentId: parentCommentId,
      );

  @override
  Future<List<TaskProgress>> fetchTaskProgresses(String taskItemId) =>
      _remote.getTaskProgresses(taskItemId);

  @override
  Future<void> createTaskProgress(
    String taskItemId, {
    required int progressPercentage,
    required DateTime loggedAt,
    String? notes,
    double? hoursWorked,
    int? status,
  }) =>
      _remote.createTaskProgress(
        taskItemId,
        progressPercentage: progressPercentage,
        loggedAt: loggedAt,
        notes: notes,
        hoursWorked: hoursWorked,
        status: status,
      );

  @override
  Future<void> updateTaskProgress(
    String taskItemId,
    String progressId, {
    required int progressPercentage,
    required DateTime loggedAt,
    required String notes,
    double? hoursWorked,
    int? status,
  }) =>
      _remote.updateTaskProgress(
        taskItemId,
        progressId,
        progressPercentage: progressPercentage,
        loggedAt: loggedAt,
        notes: notes,
        hoursWorked: hoursWorked,
        status: status,
      );

  @override
  Future<void> deleteTaskProgress(String taskItemId, String progressId) =>
      _remote.deleteTaskProgress(taskItemId, progressId);
}
