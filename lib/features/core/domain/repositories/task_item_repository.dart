import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';

abstract interface class TaskItemRepository {
  Future<List<TaskItem>> fetchTaskItems();
  Future<void> addTaskItem(TaskItem taskItem);
  Future<void> updateTaskItem(TaskItem taskItem);
  Future<void> deleteTaskItem(TaskItem taskItem);
}
