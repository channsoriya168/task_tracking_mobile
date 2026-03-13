import 'package:task_tracking_mobile/features/core/data/datasources/remote/task_item_remote_datasource.dart';
import 'package:task_tracking_mobile/features/core/data/models/task_item_model.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_item_repository.dart';

class TaskItemRepositoryImpl implements TaskItemRepository {
  final TaskItemRemoteDatasource _remote;

  TaskItemRepositoryImpl(this._remote);

  @override
  Future<List<TaskItem>> fetchTaskItems({
    String? search,
    int? statusId,
    String? groupId,
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
  }) =>
      _remote.getAll(
        search: search,
        statusId: statusId,
        groupId: groupId,
        dueDateFrom: dueDateFrom,
        dueDateTo: dueDateTo,
      );

  @override
  Future<void> addTaskItem(TaskItem taskItem) =>
      _remote.create(taskItem as TaskItemModel);

  @override
  Future<void> updateTaskItem(TaskItem taskItem) async {
    // TODO: implement update
  }

  @override
  Future<void> deleteTaskItem(TaskItem taskItem) =>
      _remote.delete(taskItem.id);

  @override
  Future<void> assignTask(String id, String assignedToId) =>
      _remote.assignTask(id, assignedToId);

  @override
  Future<void> updateTaskStatus(String id, int status) =>
      _remote.updateStatus(id, status);
}