import 'package:task_tracking_mobile/features/employee/data/datasources/employee_remote_datasource.dart';
import 'package:task_tracking_mobile/features/employee/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/employee/domain/repositories/employee_repository.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDatasource _remote;

  EmployeeRepositoryImpl(this._remote);

  @override
  Future<List<Employee>> fetchEmployees({String? name, String? groupId}) =>
      _remote.fetchEmployees(name: name, groupId: groupId);

  @override
  Future<Employee> fetchEmployeeById(String id) =>
      _remote.fetchEmployeeById(id);

  @override
  Future<Employee> createEmployee({
    required String fullName,
    String? email,
    required String password,
    required String confirmPassword,
    String? phone,
    String? placeOfBirth,
    DateTime? dateOfBirth,
    String? genderId,
    List<String>? groupIds,
    String? profileImagePath,
    String? role,
  }) => _remote.createEmployee(
    fullName: fullName,
    email: email,
    password: password,
    confirmPassword: confirmPassword,
    phone: phone,
    placeOfBirth: placeOfBirth,
    dateOfBirth: dateOfBirth,
    genderId: genderId,
    groupIds: groupIds,
    profileImagePath: profileImagePath,
    role: role,
  );

  @override
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
    String? password,
    String? confirmPassword,
    String? role,
  }) => _remote.updateEmployee(
    id,
    fullName: fullName,
    email: email,
    phone: phone,
    placeOfBirth: placeOfBirth,
    dateOfBirth: dateOfBirth,
    genderId: genderId,
    groupIds: groupIds,
    profileImagePath: profileImagePath,
    removeProfileImage: removeProfileImage,
    password: password,
    confirmPassword: confirmPassword,
    role: role,
  );

  @override
  Future<void> deleteEmployee(String id) => _remote.deleteEmployee(id);

  @override
  Future<void> resetPassword({
    required String employeeId,
    required String newPassword,
    required String confirmNewPassword,
  }) => _remote.resetPassword(
    employeeId: employeeId,
    newPassword: newPassword,
    confirmNewPassword: confirmNewPassword,
  );
}
