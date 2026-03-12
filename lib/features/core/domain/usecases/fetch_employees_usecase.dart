import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/employee_repository.dart';

class FetchEmployeesUsecase {
  final EmployeeRepository _repo;

  FetchEmployeesUsecase(this._repo);

  Future<List<Employee>> call() => _repo.fetchEmployees();
}
