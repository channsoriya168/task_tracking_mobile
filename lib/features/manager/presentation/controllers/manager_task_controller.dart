import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/features/core/data/models/task_item_model.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/label.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_priority.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_task_priorities_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_task_statuses_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/get_all_labels_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/create_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/delete_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/fetch_task_item.usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/fetch_task_item_by_id_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/update_task_item_usecase.dart';

class ManagerTaskController extends GetxController {
  final FetchTaskItemsUsecase _fetchTaskItems;
  final CreateTaskItemUsecase _createTaskItem;
  final UpdateTaskItemUsecase _updateTaskItem;
  final DeleteTaskItemUsecase _deleteTaskItem;
  final FetchTaskItemByIdUsecase _fetchTaskItemById;
  final FetchTaskPrioritiesUsecase _fetchPriorities;
  final FetchTaskStatusesUsecase _fetchStatuses;
  final GetAllLabelsUseCase _getAllLabels;

  ManagerTaskController(
    this._fetchTaskItems,
    this._fetchTaskItemById,
    this._createTaskItem,
    this._updateTaskItem,
    this._deleteTaskItem,
    this._fetchPriorities,
    this._fetchStatuses,
    this._getAllLabels,
  );

  final RxList<TaskItem> tasks = <TaskItem>[].obs;

  /// All tasks for the selected date, unfiltered by status — used for counts.
  final RxList<TaskItem> allTasks = <TaskItem>[].obs;

  final RxList<TaskPriority> taskPriority = <TaskPriority>[].obs;
  final RxList<TaskStatusLookup> taskStatus = <TaskStatusLookup>[].obs;
  final RxList<Label> labels = <Label>[].obs;

  /// Selected status name — 'All' means no status filter.
  final RxString filterStatus = 'All'.obs;

  /// Corresponding status ID sent to the API (null = no filter).
  final Rxn<int> filterStatusId = Rxn<int>();

  final RxString searchQuery = ''.obs;

  /// Selected single day from the week calendar (task page).
  final Rxn<DateTime> taskSelectedDate = Rxn<DateTime>();
  final Rxn<DateTime> currentDate = Rxn<DateTime>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final titleTextEditor = TextEditingController();
  final descTextEditor = TextEditingController();
  final RxString titleText = ''.obs;
  final selectedCategory = ''.obs;
  final selectedGroupId = Rxn<String>();
  final selectedPriority = Rxn<TaskPriority>();
  final selectedLabel = Rxn<Label>();
  final selectedDueDate = Rxn<DateTime>();
  final selectedStartDate = Rxn<DateTime>();
  final dashboardSelectedDate = Rxn<DateTime>();
  final Rxn<TaskItem> editingTask = Rxn<TaskItem>();

  /// Tasks are already server-filtered; expose as-is.
  List<TaskItem> get filteredTasks => tasks.toList();

  int countByStatus(String statusName) {
    if (statusName == 'All') return allTasks.length;
    return allTasks
        .where((t) => t.status.name.toLowerCase() == statusName.toLowerCase())
        .length;
  }

  bool get hasDateFilter => taskSelectedDate.value != null;

  @override
  void onInit() {
    super.onInit();
    // Default to today so the calendar and API filter start on the current day.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    taskSelectedDate.value = today;
    currentDate.value = today;

    fetchTasks();
    fetchPriorities();
    fetchStatuses();
    fetchLabels();

    titleTextEditor.addListener(() => titleText.value = titleTextEditor.text);

    // Re-apply client-side status filter when selection changes (no extra API call).
    ever(filterStatusId, (_) => _applyStatusFilter());

    // Debounce search so we don't hit the API on every keystroke.
    debounce(
      searchQuery,
      (_) => fetchTasks(),
      time: const Duration(milliseconds: 500),
    );
  }

  Future<TaskItem?> fetchTaskById(String id) async {
    try {
      return await _fetchTaskItemById(id);
    } catch (e) {
      AppSnackbar.error('Error', AppSnackbar.parseApiError(e, fallback: 'Could not load task.'));
      return null;
    }
  }

  Future<void> fetchTasks() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _fetchTaskItems(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        SelectedDate: taskSelectedDate.value,
      );
      allTasks.assignAll(result);
      _applyStatusFilter();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _applyStatusFilter() {
    final id = filterStatusId.value;
    if (id == null) {
      tasks.assignAll(allTasks);
    } else {
      tasks.assignAll(allTasks.where((t) => t.status.id == id));
    }
  }

  /// Select (or deselect) a single day from the week calendar.
  void selectTaskDate(DateTime? date) {
    taskSelectedDate.value = date;
    if (date == null) {
      taskSelectedDate.value = DateTime.now();
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

  /// Returns true on success, false on failure.
  Future<bool> createTask() async {
    final title = titleTextEditor.text.trim();
    final priority = selectedPriority.value;
    final groupId = selectedGroupId.value;
    if (title.isEmpty || priority == null || groupId == null) return false;

    try {
      final now = DateTime.now();
      final model = TaskItemModel(
        id: '',
        title: title,
        description: descTextEditor.text.trim().isEmpty
            ? null
            : descTextEditor.text.trim(),
        labelId: selectedLabel.value?.id,
        groupId: selectedGroupId.value,
        priority: priority,
        status: const TaskStatusLookup(id: 0, name: 'Pending'),
        startDate: DateTime(now.year, now.month, now.day),
        dueDate: selectedDueDate.value,
      );
      await _createTaskItem(model);
      await fetchTasks();
      _clearForm();
      AppSnackbar.success('Task Created', '"$title" has been created.');
      return true;
    } catch (e) {
      AppSnackbar.error(
        'Create Failed',
        AppSnackbar.parseApiError(e, fallback: 'Could not create task.'),
      );
      return false;
    }
  }

  /// Updates the current editing task from form fields. Returns true on success.
  Future<bool> updateTask() async {
    final original = editingTask.value;
    final title = titleTextEditor.text.trim();
    final priority = selectedPriority.value;
    final groupId = selectedGroupId.value;
    if (original == null ||
        title.isEmpty ||
        priority == null ||
        groupId == null) {
      return false;
    }

    final updated = TaskItemModel(
      id: original.id,
      title: title,
      description: descTextEditor.text.trim().isEmpty
          ? null
          : descTextEditor.text.trim(),
      labelId: selectedLabel.value?.id,
      groupId: groupId,
      priority: priority,
      status: original.status,
      startDate: selectedStartDate.value,
      dueDate: selectedDueDate.value,
    );

    try {
      await _updateTaskItem(updated);
      final i = tasks.indexWhere((t) => t.id == original.id);
      if (i != -1) tasks[i] = updated;
      await fetchTasks();
      _clearForm();
      AppSnackbar.success('Task Updated', '"$title" has been updated.');
      return true;
    } catch (e) {
      AppSnackbar.error(
        'Update Failed',
        AppSnackbar.parseApiError(e, fallback: 'Could not update task.'),
      );
      return false;
    }
  }

  Future<void> deleteTask(TaskItem taskItem) async {
    try {
      await _deleteTaskItem(taskItem);
      await fetchTasks();
      AppSnackbar.success(
        'Task Deleted',
        '"${taskItem.title}" has been deleted.',
      );
    } catch (e) {
      AppSnackbar.error(
        'Delete Failed',
        AppSnackbar.parseApiError(e, fallback: 'Could not delete task.'),
      );
    }
  }

  /// Populates the form from an existing task before opening the edit dialog.
  void openForEdit(TaskItem task) {
    editingTask.value = task;
    titleTextEditor.text = task.title;
    descTextEditor.text = task.description ?? '';
    selectedGroupId.value = task.groupId;
    selectedCategory.value = task.groupName ?? '';
    selectedPriority.value = task.priority;
    selectedDueDate.value = task.dueDate;
    selectedStartDate.value = task.startDate;
    selectedLabel.value = task.labelId != null
        ? labels.firstWhereOrNull((l) => l.id == task.labelId)
        : null;
  }

  /// Resets the form to defaults before opening the create-task dialog.
  void resetForm(List<TaskGroup> groups) {
    editingTask.value = null;
    titleTextEditor.clear();
    descTextEditor.clear();
    selectedLabel.value = null;
    selectedGroupId.value = groups.isNotEmpty ? groups.first.id : null;
    selectedCategory.value = groups.isNotEmpty ? groups.first.name : '';
    selectedPriority.value = taskPriority.isNotEmpty
        ? (taskPriority.firstWhereOrNull(
                (p) => p.name.toLowerCase() == 'medium',
              ) ??
              taskPriority.first)
        : null;
    final now = DateTime.now();
    selectedDueDate.value = DateTime(now.year, now.month, now.day);
    selectedStartDate.value = null;
  }

  void _clearForm() {
    editingTask.value = null;
    titleTextEditor.clear();
    descTextEditor.clear();
    selectedLabel.value = null;
    selectedGroupId.value = null;
    selectedCategory.value = '';
    selectedPriority.value = null;
    selectedStartDate.value = null;
    selectedDueDate.value = null;
  }
}
