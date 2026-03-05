import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';

class EmployeeController extends GetxController {
  final RxList<Position> positions = <Position>[].obs;
  final RxList<Employee> employees = <Employee>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    positions.addAll(kMockPositions);
    employees.addAll(kMockEmployees);
  }

  List<Employee> get filteredEmployees {
    if (searchQuery.value.isEmpty) return employees.toList();
    final q = searchQuery.value.toLowerCase();
    return employees.where((e) {
      return e.name.toLowerCase().contains(q) ||
          e.email.toLowerCase().contains(q);
    }).toList();
  }

  List<Employee> employeesByPosition(String positionId) {
    return filteredEmployees.where((e) => e.positionId == positionId).toList();
  }

  Position? findPosition(String id) {
    try {
      return positions.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  int employeeCountByPosition(String positionId) =>
      employees.where((e) => e.positionId == positionId).length;

  void addEmployee(Employee employee) => employees.add(employee);

  void updateEmployee(Employee updated) {
    final i = employees.indexWhere((e) => e.id == updated.id);
    if (i != -1) employees[i] = updated;
  }

  void deleteEmployee(String id) => employees.removeWhere((e) => e.id == id);

  void addPosition(Position position) => positions.add(position);

  void updatePosition(Position updated) {
    final i = positions.indexWhere((p) => p.id == updated.id);
    if (i != -1) positions[i] = updated;
  }

  void deletePosition(String id) {
    positions.removeWhere((p) => p.id == id);
    employees.removeWhere((e) => e.positionId == id);
  }

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}
