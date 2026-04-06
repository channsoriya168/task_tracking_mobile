import 'package:task_tracking_mobile/features/employee/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/employee/domain/repositories/employee_repository.dart';

class UpdateEmployeeUsecase {
  final EmployeeRepository _repository;

  UpdateEmployeeUsecase(this._repository);

  Future<Employee> call(
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
  }) => _repository.updateEmployee(
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
}
