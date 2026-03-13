import 'package:dio/dio.dart';
import 'package:task_tracking_mobile/app/services/api_client.dart';
import 'package:task_tracking_mobile/app/utils/api_endpoints.dart';
import 'package:task_tracking_mobile/features/core/data/models/task_item_model.dart';

class TaskItemRemoteDatasource {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<TaskItemModel>> getAll() async {
    final response = await _dio.get(ApiEndpoints.taskItems);
    return (response.data as List)
        .map((e) => TaskItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TaskItemModel> create(TaskItemModel taskItem) async {
    final response = await _dio.post(
      ApiEndpoints.taskItems,
      data: taskItem.toJson(),
    );
    return TaskItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TaskItemModel> update(String id, TaskItemModel taskItem) async {
    final response = await _dio.put(
      ApiEndpoints.taskItemById(id),
      data: taskItem.toJson(),
    );
    return TaskItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete(ApiEndpoints.taskItemById(id));
  }
}
