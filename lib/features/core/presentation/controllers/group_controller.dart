import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/create_group_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/get_all_groups_usecase.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_controller.dart';

class TaskGroupController extends GetxController {
  final RxList<TaskGroup> taskGroups = <TaskGroup>[].obs;
  final GetAllTaskGroupsUseCase _getAllTaskGroups;
  final CreateTaskGroupUseCase _createTaskGroup;
  TaskGroupController(this._getAllTaskGroups, this._createTaskGroup);

  static const Color kDefaultTaskGroupColor = Color(0xFF6C63FF);
  final TextEditingController nameEditingController = TextEditingController();
  final TextEditingController descriptionEditingController =
      TextEditingController();
  final Rxn<Color> selectedColor = Rxn<Color>(kDefaultTaskGroupColor);

  @override
  void onInit() {
    super.onInit();
    fetchTaskGroups();
  }

  Future<void> fetchTaskGroups() async {
    try {
      taskGroups.assignAll(await _getAllTaskGroups());
    } catch (_) {
      AppSnackbar.error('snack_label'.tr, 'snack_group_load_fail'.tr);
    }
  }

  void initTaskGroupForm(TaskGroup? existing) {
    nameEditingController.text = existing?.name ?? '';
    descriptionEditingController.text = existing?.description ?? '';
    selectedColor.value = existing?.color ?? kDefaultTaskGroupColor;
  }

  @override
  void onClose() {
    nameEditingController.dispose();
    descriptionEditingController.dispose();
    super.onClose();
  }

  TaskGroup? findPosition(String id) {
    try {
      return taskGroups.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> createTaskGroup({
    required String name,
    Color? color,
    String? description,
  }) async {
    try {
      final taskGroup = await _createTaskGroup(
        name: name,
        color: _toHexColor(color),
        description: description,
      );
      taskGroups.add(taskGroup);
      AppSnackbar.success(
        'snack_group_added'.tr,
        'snack_group_added_msg'.trParams({'name': taskGroup.name}),
      );
      return true;
    } catch (_) {
      AppSnackbar.error('snack_label'.tr, 'snack_group_create_fail'.tr);
      return false;
    }
  }

  void updateTaskGroup(TaskGroup updated) {
    final i = taskGroups.indexWhere((p) => p.id == updated.id);
    if (i == -1) return;
    taskGroups[i] = updated;
    AppSnackbar.update(
      'snack_group_updated'.tr,
      'snack_group_updated_msg'.trParams({'name': updated.name}),
    );
  }

  void deleteTaskGroup(String id) {
    final taskGroup = findPosition(id);
    if (taskGroup == null) return;
    taskGroups.removeWhere((p) => p.id == id);
    Get.find<EmployeeController>().fetchEmployees();
    AppSnackbar.delete(
      'snack_group_deleted'.tr,
      'snack_group_deleted_msg'.trParams({'name': taskGroup.name}),
    );
  }

  // ── Employee helpers ──────────────────────────────────────────
  List<Employee> employeesByTaskGroup(String groupId) {
    return Get.find<EmployeeController>()
        .filteredEmployees
        .where((e) => e.taskGroups.any((g) => g.groupId == groupId))
        .toList();
  }

  int employeeCountByTaskGroup(String groupId) => Get.find<EmployeeController>()
      .employees
      .where((e) => e.taskGroups.any((g) => g.groupId == groupId))
      .length;

  TaskGroup? taskGroupForEmployee(Employee emp) {
    if (emp.taskGroups.isEmpty) return null;
    final g = emp.taskGroups.first;
    return findPosition(g.groupId) ??
        TaskGroup(id: g.groupId, name: g.groupName, color: g.groupColor);
  }

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  String? _toHexColor(Color? color) {
    if (color == null) return null;
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
