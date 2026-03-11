import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/get_all_task_groups_usecase.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';

class TaskGroupController extends GetxController {
  final RxList<TaskGroup> taskGroups = <TaskGroup>[].obs;
  final GetAllTaskGroupsUseCase _getAllTaskGroups;
  TaskGroupController(this._getAllTaskGroups);
  final TextEditingController nameEditingController = TextEditingController();
  final TextEditingController descriptionEditingController =
      TextEditingController();
  final TextEditingController colorEditingController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchTaskGroups();
  }

  Future<void> fetchTaskGroups() async {
    try {
      taskGroups.assignAll(await _getAllTaskGroups());
    } catch (_) {
      AppSnackbar.error('Positions', 'Failed to load positions.');
    }
  }

  TaskGroup? findPosition(String id) {
    try {
      return taskGroups.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void addPosition(TaskGroup position) {
    taskGroups.add(position);
    AppSnackbar.success(
      'Position Added',
      '"${position.name}" has been created.',
    );
  }

  void updatePosition(TaskGroup updated) {
    final i = taskGroups.indexWhere((p) => p.id == updated.id);
    if (i == -1) return;
    taskGroups[i] = updated;
    AppSnackbar.update(
      'Position Updated',
      '"${updated.name}" has been updated.',
    );
  }

  void deletePosition(String id) {
    final pos = findPosition(id);
    if (pos == null) return;
    taskGroups.removeWhere((p) => p.id == id);
    Get.find<EmployeeController>().employees.removeWhere(
      (e) => e.positionId == id,
    );
    AppSnackbar.delete('Position Deleted', '"${pos.name}" has been removed.');
  }

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}
