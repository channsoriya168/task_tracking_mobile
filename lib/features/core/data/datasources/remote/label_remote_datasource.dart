import 'package:dio/dio.dart';
import 'package:task_tracking_mobile/app/services/api_client.dart';
import 'package:task_tracking_mobile/app/utils/api_endpoints.dart';
import 'package:task_tracking_mobile/features/core/data/models/label_model.dart';

class LabelRemoteDatasource {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<LabelModel>> getAll() async {
    final response = await _dio.get(ApiEndpoints.labels);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => LabelModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LabelModel> create({
    required String name,
    String? description,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.labels,
      data: {
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
    return LabelModel.fromJson(response.data as Map<String, dynamic>);
  }
}
