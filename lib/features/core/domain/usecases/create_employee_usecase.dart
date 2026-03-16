import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/employee_repository.dart';

class CreateEmployeeUsecase {
  final EmployeeRepository _repo;

  CreateEmployeeUsecase(this._repo);

  Future<Employee> call({
    required String fullName,
    String? email,
    required String password,
    required String confirmPassword,
    String? phone,
    String? placeOfBirth,
    DateTime? dateOfBirth,
    List<String>? groupIds,
    String? profileImagePath,
  }) => _repo.createEmployee(
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
}
