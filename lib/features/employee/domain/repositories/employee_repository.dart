import 'package:task_tracking_mobile/features/employee/domain/entities/employee.dart';

abstract class EmployeeRepository {
  Future<List<Employee>> fetchEmployees({String? name, String? groupId});
  Future<Employee> fetchEmployeeById(String id);
  Future<Employee> createEmployee({
    required String fullName,
    String? email,
    String? phone,
    String? placeOfBirth,
    DateTime? dateOfBirth,
    String? genderId,
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
    String? genderId,
    List<String>? groupIds,
    String? profileImagePath,
    bool removeProfileImage = false,
    String? role,
  });

  Future<void> deleteEmployee(String id);
}
