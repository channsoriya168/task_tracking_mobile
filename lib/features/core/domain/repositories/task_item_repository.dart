import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';

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
}
