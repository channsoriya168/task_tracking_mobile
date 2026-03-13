import 'dart:async';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/delete_employee_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_employees_usecase.dart';

class AdminEmployeeController extends GetxController {
  final FetchEmployeesUsecase _fetchEmployees;
  final DeleteEmployeeUsecase _deleteEmployee;

  AdminEmployeeController(this._fetchEmployees, this._deleteEmployee);

  final RxList<Employee> employees = <Employee>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedGroupId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();

    // Re-fetch from API whenever search or group filter changes
    ever(searchQuery, (_) => _onFilterChanged());
    ever(selectedGroupId, (_) => _onFilterChanged());
  }

  void _onFilterChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      fetchEmployees(
        name: searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim(),
        groupId: selectedGroupId.value.isEmpty ? null : selectedGroupId.value,
      );
    });
  }

  Future<void> fetchEmployees({String? name, String? groupId}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      employees.value = await _fetchEmployees(name: name, groupId: groupId);
    } catch (e) {
      errorMessage.value = 'Failed to load employees.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteEmployee(String id) async {
    try {
      await _deleteEmployee(id);
      employees.removeWhere((e) => e.id == id);
      AppSnackbar.delete('Employee Deleted', 'Employee has been removed.');
      return true;
    } catch (_) {
      AppSnackbar.error('Delete Employee', 'Failed to delete employee.');
      return false;
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
