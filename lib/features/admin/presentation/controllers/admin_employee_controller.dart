import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/position_controller.dart';

class AdminEmployeeController extends GetxController {
  final RxString searchQuery = ''.obs;
  final RxString selectedPositionId = ''.obs; // '' = All

  RxList<Employee> get employees => Get.find<EmployeeController>().employees;
  RxList<Position> get positions => Get.find<PositionController>().positions;

  List<Employee> get filteredEmployees {
    return employees.where((e) {
      final matchesPosition = selectedPositionId.value.isEmpty ||
          e.positionId == selectedPositionId.value;
      final q = searchQuery.value.toLowerCase();
      final matchesSearch = q.isEmpty ||
          e.name.toLowerCase().contains(q) ||
          e.email.toLowerCase().contains(q);
      return matchesPosition && matchesSearch;
    }).toList();
  }

  Position? findPosition(String id) =>
      Get.find<PositionController>().findPosition(id);
}
