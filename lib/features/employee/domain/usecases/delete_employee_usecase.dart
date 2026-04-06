import 'package:task_tracking_mobile/features/employee/domain/repositories/employee_repository.dart';

class DeleteEmployeeUsecase {
  final EmployeeRepository _repository;

  DeleteEmployeeUsecase(this._repository);

  Future<void> call(String id) => _repository.deleteEmployee(id);
}
