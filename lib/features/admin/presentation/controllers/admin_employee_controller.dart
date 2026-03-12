import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_employees_usecase.dart';

class AdminEmployeeController extends GetxController {
  final FetchEmployeesUsecase _fetchEmployees;

  AdminEmployeeController(this._fetchEmployees);

  final RxList<Employee> employees = <Employee>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedGroupId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  List<EmployeeTaskGroup> get groups {
    final seen = <String>{};
    final result = <EmployeeTaskGroup>[];
    for (final emp in employees) {
      for (final g in emp.taskGroups) {
        if (seen.add(g.groupId)) result.add(g);
      }
    }
    return result;
  }

  List<Employee> get filteredEmployees {
    return employees.where((e) {
      final matchesGroup =
          selectedGroupId.value.isEmpty ||
          e.taskGroups.any((g) => g.groupId == selectedGroupId.value);
      final q = searchQuery.value.toLowerCase();
      final matchesSearch =
          q.isEmpty ||
          e.fullName.toLowerCase().contains(q) ||
          e.email.toLowerCase().contains(q);
      return matchesGroup && matchesSearch;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      employees.value = await _fetchEmployees();
    } catch (e) {
      errorMessage.value = 'Failed to load employees.';
    } finally {
      isLoading.value = false;
    }
  }
}
