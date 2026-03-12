import 'package:dio/dio.dart';
import 'package:task_tracking_mobile/app/services/api_client.dart';
import 'package:task_tracking_mobile/app/utils/api_endpoints.dart';
import 'package:task_tracking_mobile/features/core/data/models/employee_model.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';

class EmployeeRemoteDatasource {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<Employee>> fetchEmployees() async {
    final response = await _dio.get(ApiEndpoints.employees);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Employee> fetchEmployeeById(String id) async {
    final response = await _dio.get(ApiEndpoints.employeeById(id));
    return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
  }
}
