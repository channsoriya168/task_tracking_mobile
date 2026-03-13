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

  Future<Employee> createEmployee({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    String? phone,
    String? placeOfBirth,
    DateTime? dateOfBirth,
    List<String>? groupIds,
    String? profileImagePath,
  }) async {
    final formData = FormData();

    // ── Text fields ───────────────────────────────────────────
    formData.fields.addAll([
      MapEntry('fullName', fullName),
      MapEntry('email', email),
      MapEntry('password', password),
      MapEntry('confirmPassword', confirmPassword),
      if (phone != null && phone.isNotEmpty) MapEntry('phone', phone),
      if (placeOfBirth != null && placeOfBirth.isNotEmpty)
        MapEntry('placeOfBirth', placeOfBirth),
      if (dateOfBirth != null)
        MapEntry('dateOfBirth', dateOfBirth.toIso8601String().split('T').first),
    ]);

    // ── Group IDs — repeated field names (ASP.NET array binding) ──
    if (groupIds != null) {
      for (final id in groupIds) {
        formData.fields.add(MapEntry('groupIds', id));
      }
    }

    // ── Profile image ─────────────────────────────────────────
    if (profileImagePath != null) {
      final filename = profileImagePath.split('/').last;
      final ext = filename.split('.').last.toLowerCase();
      final mime = ext == 'png'
          ? DioMediaType('image', 'png')
          : DioMediaType('image', 'jpeg');
      formData.files.add(MapEntry(
        'profileImage',
        await MultipartFile.fromFile(
          profileImagePath,
          filename: filename,
          contentType: mime,
        ),
      ));
    }

    final response = await _dio.post(ApiEndpoints.employees, data: formData);
    return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Employee> updateEmployee(
    String id, {
    required String fullName,
    required String email,
    String? phone,
    String? placeOfBirth,
    DateTime? dateOfBirth,
    List<String>? groupIds,
    String? profileImagePath,
    bool removeProfileImage = false,
  }) async {
    final formData = FormData();

    formData.fields.addAll([
      MapEntry('fullName', fullName),
      MapEntry('email', email),
      MapEntry('removeProfileImage', removeProfileImage.toString()),
      if (phone != null && phone.isNotEmpty) MapEntry('phone', phone),
      if (placeOfBirth != null && placeOfBirth.isNotEmpty)
        MapEntry('placeOfBirth', placeOfBirth),
      if (dateOfBirth != null)
        MapEntry('dateOfBirth', dateOfBirth.toIso8601String().split('T').first),
    ]);

    if (groupIds != null) {
      for (final gId in groupIds) {
        formData.fields.add(MapEntry('groupIds', gId));
      }
    }

    if (profileImagePath != null) {
      final filename = profileImagePath.split('/').last;
      final ext = filename.split('.').last.toLowerCase();
      final mime = ext == 'png'
          ? DioMediaType('image', 'png')
          : DioMediaType('image', 'jpeg');
      formData.files.add(MapEntry(
        'profileImage',
        await MultipartFile.fromFile(
          profileImagePath,
          filename: filename,
          contentType: mime,
        ),
      ));
    }

    final response = await _dio.put(
      ApiEndpoints.employeeById(id),
      data: formData,
    );
    return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteEmployee(String id) async {
    await _dio.delete(ApiEndpoints.employeeById(id));
  }
}
