import 'package:task_tracking_mobile/features/employee/domain/repositories/employee_repository.dart';

class ResetEmployeePasswordUsecase {
  const ResetEmployeePasswordUsecase(this._repository);

  final EmployeeRepository _repository;

  Future<void> call({
    required String employeeId,
    required String newPassword,
    required String confirmNewPassword,
  }) => _repository.resetPassword(
    employeeId: employeeId,
    newPassword: newPassword,
    confirmNewPassword: confirmNewPassword,
  );
}
