import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';

abstract class EmployeeRepository {
  Future<List<Employee>> fetchEmployees({String? name, String? groupId});
  Future<Employee> fetchEmployeeById(String id);
  Future<Employee> createEmployee({
    required String fullName,
    String? email,
    required String password,
    required String confirmPassword,
    String? phone,
    String? placeOfBirth,
    DateTime? dateOfBirth,
    List<String>? groupIds,
    String? profileImagePath,
    String? role,
  });

  Future<Employee> updateEmployee(
    String id, {
    required String fullName,
    String? email,
    String? phone,
    String? placeOfBirth,
    DateTime? dateOfBirth,
    List<String>? groupIds,
    String? profileImagePath,
    bool removeProfileImage = false,
    String? password,
    String? confirmPassword,
    String? role,
  });

  Future<void> deleteEmployee(String id);

  Future<void> resetPassword({
    required String employeeId,
    required String newPassword,
    required String confirmNewPassword,
  });
}
