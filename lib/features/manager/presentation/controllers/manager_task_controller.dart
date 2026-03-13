import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_priority.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_task_priorities_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/create_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/delete_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/fetch_task_item.usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/update_task_item_usecase.dart';

class ManagerTaskController extends GetxController {
  final FetchTaskItemsUsecase _fetchTaskItems;
  final CreateTaskItemUsecase _createTaskItem;
  final UpdateTaskItemUsecase _updateTaskItem;
  final DeleteTaskItemUsecase _deleteTaskItem;
  final FetchTaskPrioritiesUsecase _fetchPriorities;

  ManagerTaskController(
    this._fetchTaskItems,
    this._createTaskItem,
    this._updateTaskItem,
    this._deleteTaskItem,
    this._fetchPriorities,
  );

  final RxList<TaskItem> tasks = <TaskItem>[].obs;
  final RxList<TaskPriority> availablePriorities = <TaskPriority>[].obs;
  final RxString filterStatus = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final titleTextEditor = TextEditingController();
  final descTextEditor = TextEditingController();
  final selectedCategory = ''.obs;
  final selectedGroupId = Rxn<String>();
  final selectedPriority = Rxn<TaskPriority>();
  final selectedDueDate = Rxn<DateTime>();
  final dashboardSelectedDate = Rxn<DateTime>();

  List<TaskItem> get filteredTasks {
    var result = tasks.toList();
    if (filterStatus.value != 'All') {
      result = result
          .where(
            (t) =>
                t.status.name.toLowerCase() ==
                filterStatus.value.toLowerCase(),
          )
          .toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result
          .where(
            (t) =>
                t.title.toLowerCase().contains(q) ||
                (t.description ?? '').toLowerCase().contains(q) ||
                (t.groupName ?? '').toLowerCase().contains(q),
          )
          .toList();
    }
    return result;
  }

  int countByStatus(String filter) {
    if (filter == 'All') return tasks.length;
    return tasks
        .where(
          (t) =>
              t.status.name.toLowerCase() == filter.toLowerCase(),
        )
        .length;
  }

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
    fetchPriorities();
  }

  Future<void> fetchTasks() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _fetchTaskItems();
      tasks.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPriorities() async {
    try {
      final result = await _fetchPriorities();
      availablePriorities.assignAll(result);
      if (selectedPriority.value == null && result.isNotEmpty) {
        selectedPriority.value =
            result.firstWhereOrNull(
              (p) => p.name.toLowerCase() == 'medium',
            ) ??
            result.first;
      }
    } catch (_) {}
  }

  Future<void> createTask() async {
    try {
      await fetchTasks();
      _clearForm();
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  Future<void> updateTask(TaskItem updated) async {
    try {
      await _updateTaskItem(updated);
      final i = tasks.indexWhere((t) => t.id == updated.id);
      if (i != -1) tasks[i] = updated;
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  Future<void> deleteTask(TaskItem taskItem) async {
    try {
      await _deleteTaskItem(taskItem);
      tasks.removeWhere((t) => t.id == taskItem.id);
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  void _clearForm() {
    titleTextEditor.clear();
    descTextEditor.clear();
    selectedGroupId.value = null;
    selectedCategory.value = '';
    selectedDueDate.value = null;
    selectedPriority.value = availablePriorities.isNotEmpty
        ? (availablePriorities.firstWhereOrNull(
              (p) => p.name.toLowerCase() == 'medium',
            ) ??
            availablePriorities.first)
        : null;
  }
}