import 'package:dio/dio.dart';
import 'package:task_tracking_mobile/core/network/api_client.dart';
import 'package:task_tracking_mobile/core/network/api_endpoints.dart';
import 'package:task_tracking_mobile/features/core/data/models/group_model.dart';

class GroupRemoteDatasource {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<GroupModel>> getAll() async {
    final response = await _dio.get(ApiEndpoints.groups);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<GroupModel> create(GroupModel group) async {
    final response = await _dio.post(
      ApiEndpoints.groups,
      data: group.toRequestJson(),
    );
    return GroupModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<GroupModel> update(String id, GroupModel group) async {
    final response = await _dio.put(
      ApiEndpoints.groupById(id),
      data: group.toRequestJson(),
    );
    return GroupModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete(ApiEndpoints.groupById(id));
  }
}
