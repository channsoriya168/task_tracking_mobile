import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';

abstract class EmployeeRepository {
  Future<List<Employee>> fetchEmployees();
  Future<Employee> fetchEmployeeById(String id);
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
  });
}
