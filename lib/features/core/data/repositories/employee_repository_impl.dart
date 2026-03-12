import 'package:task_tracking_mobile/features/core/data/datasources/remote/employee_remote_datasource.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/employee_repository.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDatasource _remote;

  EmployeeRepositoryImpl(this._remote);

  @override
  Future<List<Employee>> fetchEmployees() => _remote.fetchEmployees();

  @override
  Future<Employee> fetchEmployeeById(String id) =>
      _remote.fetchEmployeeById(id);

  @override
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
  }) => _remote.createEmployee(
        fullName: fullName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        phone: phone,
        placeOfBirth: placeOfBirth,
        dateOfBirth: dateOfBirth,
        groupIds: groupIds,
        profileImagePath: profileImagePath,
      );

  @override
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
  }) => _remote.updateEmployee(
        id,
        fullName: fullName,
        email: email,
        phone: phone,
        placeOfBirth: placeOfBirth,
        dateOfBirth: dateOfBirth,
        groupIds: groupIds,
        profileImagePath: profileImagePath,
        removeProfileImage: removeProfileImage,
      );

  @override
  Future<void> deleteEmployee(String id) => _remote.deleteEmployee(id);
}
