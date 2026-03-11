import 'package:task_tracking_mobile/features/admin/data/datasources/employee_remote_datasource.dart';
import 'package:task_tracking_mobile/features/admin/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/admin/domain/repositories/employee_repository.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDatasource _remote;

  EmployeeRepositoryImpl(this._remote);

  @override
  Future<List<Employee>> fetchEmployees() => _remote.fetchEmployees();
}
