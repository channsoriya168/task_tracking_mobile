import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/core/data/models/task_item_model.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/label.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_priority.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_task_priorities_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_task_statuses_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/get_all_labels_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/create_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/delete_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/fetch_task_item.usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/update_task_item_usecase.dart';

class AdminTaskController extends GetxController {
  final FetchTaskItemsUsecase _fetchTaskItems;
  final CreateTaskItemUsecase _createTaskItem;
  final UpdateTaskItemUsecase _updateTaskItem;
  final DeleteTaskItemUsecase _deleteTaskItem;
  final FetchTaskPrioritiesUsecase _fetchPriorities;
  final FetchTaskStatusesUsecase _fetchStatuses;
  final GetAllLabelsUseCase _getAllLabels;

  AdminTaskController(
    this._fetchTaskItems,
    this._createTaskItem,
    this._updateTaskItem,
    this._deleteTaskItem,
    this._fetchPriorities,
    this._fetchStatuses,
    this._getAllLabels,
  );

  final RxList<TaskItem> tasks = <TaskItem>[].obs;
  final RxList<TaskPriority> taskPriority = <TaskPriority>[].obs;
  final RxList<TaskStatusLookup> taskStatus = <TaskStatusLookup>[].obs;
  final RxList<Label> labels = <Label>[].obs;

  /// Selected status name — 'All' means no status filter.
  final RxString filterStatus = 'All'.obs;

  /// Corresponding status ID sent to the API (null = no filter).
  final Rxn<int> filterStatusId = Rxn<int>();

  final RxString searchQuery = ''.obs;

  /// Selected single day from the week calendar.
  final Rxn<DateTime> taskSelectedDate = Rxn<DateTime>();

  /// Due-date range filter sent to the API.
  final Rxn<DateTime> filterDueDateFrom = Rxn<DateTime>();
  final Rxn<DateTime> filterDueDateTo = Rxn<DateTime>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final titleTextEditor = TextEditingController();
  final descTextEditor = TextEditingController();
  final selectedCategory = ''.obs;
  final selectedGroupId = Rxn<String>();
  final selectedPriority = Rxn<TaskPriority>();
  final selectedLabel = Rxn<Label>();
  final selectedDueDate = Rxn<DateTime>();
  final selectedStartDate = Rxn<DateTime>();
  final dashboardSelectedDate = Rxn<DateTime>();

  /// Tasks are already server-filtered; expose as-is.
  List<TaskItem> get filteredTasks => tasks.toList();

  int countByStatus(String statusName) {
    if (statusName == 'All') return tasks.length;
    return tasks
        .where((t) => t.status.name.toLowerCase() == statusName.toLowerCase())
        .length;
  }

  bool get hasDateFilter => taskSelectedDate.value != null;

  int get totalTasks => tasks.length;
  int get inProgressTasks =>
      tasks.where((t) => t.status.name.toLowerCase() == 'inprogress').length;
  int get completedTasks =>
      tasks.where((t) => t.status.name.toLowerCase() == 'completed').length;

  @override
  void onInit() {
    super.onInit();
    // Default to today so the calendar and API filter start on the current day.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    taskSelectedDate.value = today;
    filterDueDateFrom.value = today;
    filterDueDateTo.value = DateTime(now.year, now.month, now.day, 23, 59, 59);

    fetchTasks();
    fetchPriorities();
    fetchStatuses();
    fetchLabels();

    // Re-fetch when status filter changes.
    ever(filterStatusId, (_) => fetchTasks());

    // Debounce search so we don't hit the API on every keystroke.
    debounce(
      searchQuery,
      (_) => fetchTasks(),
      time: const Duration(milliseconds: 500),
    );
  }

  Future<void> fetchTasks() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _fetchTaskItems(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        statusId: filterStatusId.value,
        SelectedDate: filterDueDateFrom.value,
      );
      tasks.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Select (or deselect) a single day from the week calendar.
  void selectTaskDate(DateTime? date) {
    taskSelectedDate.value = date;
    if (date == null) {
      filterDueDateFrom.value = null;
      filterDueDateTo.value = null;
    } else {
      filterDueDateFrom.value = DateTime(date.year, date.month, date.day);
      filterDueDateTo.value = DateTime(
        date.year,
        date.month,
        date.day,
        23,
        59,
        59,
      );
    }
    fetchTasks();
  }

  /// Select a status chip. Pass null to clear (show all).
  void selectStatus(TaskStatusLookup? status) {
    if (status == null) {
      filterStatus.value = 'All';
      filterStatusId.value = null;
    } else {
      filterStatus.value = status.name;
      filterStatusId.value = status.id;
    }
  }

  Future<void> fetchPriorities() async {
    try {
      final result = await _fetchPriorities();
      if (result.isNotEmpty) taskPriority.assignAll(result);
    } catch (_) {}
  }

  Future<void> fetchStatuses() async {
    try {
      final result = await _fetchStatuses();
      if (result.isNotEmpty) taskStatus.assignAll(result);
    } catch (_) {}
  }

  Future<void> fetchLabels() async {
    try {
      final result = await _getAllLabels();
      if (result.isNotEmpty) labels.assignAll(result);
    } catch (_) {}
  }

  Future<void> createTask() async {
    final label = selectedLabel.value;
    final priority = selectedPriority.value;
    if (label == null || priority == null) return;

    try {
      final model = TaskItemModel(
        id: '',
        title: label.name,
        labelId: label.id,
        groupId: selectedGroupId.value,
        priority: priority,
        status: const TaskStatusLookup(id: 0, name: 'Pending'),
        startDate: selectedStartDate.value,
        dueDate: selectedDueDate.value,
      );
      await _createTaskItem(model);
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
    selectedLabel.value = null;
    selectedGroupId.value = null;
    selectedCategory.value = '';
    selectedPriority.value = null;
    selectedStartDate.value = null;
    selectedDueDate.value = null;
  }
}
