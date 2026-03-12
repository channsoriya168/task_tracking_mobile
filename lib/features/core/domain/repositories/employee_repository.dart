import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';

abstract class EmployeeRepository {
  Future<List<Employee>> fetchEmployees();
}
