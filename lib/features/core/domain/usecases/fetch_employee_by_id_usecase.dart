import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/employee_repository.dart';

class FetchEmployeeByIdUsecase {
  final EmployeeRepository _repo;

  FetchEmployeeByIdUsecase(this._repo);

  Future<Employee> call(String id) => _repo.fetchEmployeeById(id);
}
