import 'package:dio/dio.dart';
import 'package:task_tracking_mobile/app/services/api_client.dart';
import 'package:task_tracking_mobile/app/utils/api_endpoints.dart';
import 'package:task_tracking_mobile/features/core/data/models/task_group_model.dart';

class TaskGroupRemoteDatasource {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<TaskGroupModel>> getAll() async {
    final response = await _dio.get(ApiEndpoints.taskGroups);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => TaskGroupModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TaskGroupModel> getById(String id) async {
    final response = await _dio.get(ApiEndpoints.taskGroupById(id));
    return TaskGroupModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TaskGroupModel> create(TaskGroupModel taskGroup) async {
    final response = await _dio.post(
      ApiEndpoints.taskGroups,
      data: taskGroup.toRequestJson(),
    );
    return TaskGroupModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TaskGroupModel> update(String id, TaskGroupModel taskGroup) async {
    final response = await _dio.put(
      ApiEndpoints.taskGroupById(id),
      data: taskGroup.toRequestJson(),
    );
    return TaskGroupModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete(ApiEndpoints.taskGroupById(id));
  }
}
