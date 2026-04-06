import 'package:dio/dio.dart';
import 'package:task_tracking_mobile/core/network/api_client.dart';
import 'package:task_tracking_mobile/core/network/api_endpoints.dart';
import 'package:task_tracking_mobile/features/lookup/data/models/lookup_gender_model.dart';
import 'package:task_tracking_mobile/features/lookup/data/models/task_priority_model.dart';
import 'package:task_tracking_mobile/features/lookup/data/models/task_item_status_model.dart';

class LookupRemoteDatasource {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<TaskPriorityModel>> getTaskPriorities() async {
    final response = await _dio.get(ApiEndpoints.lookupTaskPriorities);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => TaskPriorityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<TaskItemStatusModel>> getTaskStatuses() async {
    final response = await _dio.get(ApiEndpoints.lookupTaskStatuses);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => TaskItemStatusModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<LookupGenderModel>> getGenders() async {
    final response = await _dio.get(ApiEndpoints.lookupGenders);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => LookupGenderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
