import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/admin/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/admin/domain/repositories/employee_repository.dart';
import 'package:task_tracking_mobile/features/admin/domain/usecases/fetch_employees_usecase.dart';

class AdminEmployeeController extends GetxController {
  final EmployeeRepository _repo;

  AdminEmployeeController(this._repo);

  final RxList<Employee> employees = <Employee>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedGroupId = ''.obs; // '' = All
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// Unique task groups derived from all loaded employees.
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
      employees.value = await FetchEmployeesUsecase(_repo).call();
    } catch (e) {
      errorMessage.value = 'Failed to load employees.';
    } finally {
      isLoading.value = false;
    }
  }
}
