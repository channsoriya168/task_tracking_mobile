import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/employee_repository.dart';

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
    List<String>? groupIds,
    String? profileImagePath,
    bool removeProfileImage = false,
  }) => _repository.updateEmployee(
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
}
