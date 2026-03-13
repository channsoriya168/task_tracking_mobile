import 'package:dio/dio.dart';
import 'package:task_tracking_mobile/app/utils/dio_error_mapper.dart';
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
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
  }) async {
    try {
      return await _remote.getAll(
        search: search,
        statusId: statusId,
        dueDateFrom: dueDateFrom,
        dueDateTo: dueDateTo,
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> addTaskItem(TaskItem taskItem) async {
    try {
      await _remote.create(taskItem as TaskItemModel);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> updateTaskItem(TaskItem taskItem) async {
    try {
      // await _remote.update(taskItem.id, _toModel(taskItem));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> deleteTaskItem(TaskItem taskItem) async {
    try {
      await _remote.delete(taskItem.id);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}