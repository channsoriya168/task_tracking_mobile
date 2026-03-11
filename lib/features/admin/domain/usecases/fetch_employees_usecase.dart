import 'package:task_tracking_mobile/features/admin/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/admin/domain/repositories/employee_repository.dart';

class FetchEmployeesUsecase {
  final EmployeeRepository _repo;

  FetchEmployeesUsecase(this._repo);

  Future<List<Employee>> call() => _repo.fetchEmployees();
}
