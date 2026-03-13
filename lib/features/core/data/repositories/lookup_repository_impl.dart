import 'package:dio/dio.dart';
import 'package:task_tracking_mobile/app/utils/dio_error_mapper.dart';
import 'package:task_tracking_mobile/features/core/data/datasources/remote/lookup_remote_datasource.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_priority.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/lookup_repository.dart';

class LookupRepositoryImpl implements LookupRepository {
  final LookupRemoteDatasource _datasource;

  LookupRepositoryImpl(this._datasource);

  @override
  Future<List<TaskPriority>> fetchTaskPriorities() async {
    try {
      return await _datasource.getTaskPriorities();
    } on DioException catch (e) {
      throw Exception(mapDioError(e));
    }
  }

  @override
  Future<List<TaskStatusLookup>> fetchTaskStatuses() async {
    try {
      return await _datasource.getTaskStatuses();
    } on DioException catch (e) {
      throw Exception(mapDioError(e));
    }
  }
}