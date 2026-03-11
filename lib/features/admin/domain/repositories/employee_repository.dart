import 'package:task_tracking_mobile/features/admin/domain/entities/employee.dart';

abstract class EmployeeRepository {
  Future<List<Employee>> fetchEmployees();
}
