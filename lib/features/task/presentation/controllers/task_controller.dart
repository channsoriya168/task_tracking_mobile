import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/features/task/data/models/task_item_model.dart';
import 'package:task_tracking_mobile/features/label/domain/entities/label.dart';
import 'package:task_tracking_mobile/features/group/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/lookup/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/lookup/domain/entities/task_priority.dart';
import 'package:task_tracking_mobile/features/lookup/domain/usecases/fetch_task_priorities_usecase.dart';
import 'package:task_tracking_mobile/features/lookup/domain/usecases/fetch_task_statuses_usecase.dart';
import 'package:task_tracking_mobile/features/label/domain/usecases/get_all_labels_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/create_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/delete_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/fetch_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/fetch_task_item_by_id_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/update_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_bottom_sheet.dart';

class TaskController extends GetxController {
  final FetchTaskItemsUsecase _fetchTaskItems;
  final CreateTaskItemUsecase _createTaskItem;
  final UpdateTaskItemUsecase _updateTaskItem;
  final DeleteTaskItemUsecase _deleteTaskItem;
  final FetchTaskItemByIdUsecase _fetchTaskItemById;
  final FetchTaskPrioritiesUsecase _fetchPriorities;
  final FetchTaskStatusesUsecase _fetchStatuses;
  final GetAllLabelsUseCase _getAllLabels;

  TaskController(
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
  final RxBool isSaving = false.obs;
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

  bool get isEditing => editingTask.value != null;

  bool get canSubmit =>
      titleText.value.trim().isNotEmpty &&
      selectedGroupId.value != null &&
      selectedPriority.value != null &&
      selectedLabel.value != null &&
      selectedDueDate.value != null;

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

    // Auto-refresh when internet is restored — also retry labels/priorities
    // which may have failed if the page was never visited while online.
    ever(Get.find<NetworkController>().connectionStatus, (status) {
      if (status == ConnectionStatus.reconnected) {
        fetchTasks();
        fetchStatuses();
        if (taskPriority.isEmpty) fetchPriorities();
        if (labels.isEmpty) fetchLabels();
      }
    });
  }

  Future<TaskItem?> fetchTaskById(String id) async {
    try {
      return await _fetchTaskItemById(id);
    } catch (e) {
      AppSnackbar.error(
        'snack_error'.tr,
        AppSnackbar.parseApiError(e, fallback: 'snack_task_load_fail'.tr),
      );
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

  //show task sheet
  void showTaskSheet([TaskItem? task]) {
    TaskBottomSheet.showTaskSheet(Get.isDarkMode, task: task);
  }

  /// Returns true on success, false on failure.
  Future<bool> createTask() async {
    final title = titleTextEditor.text.trim();
    final priority = selectedPriority.value;
    final groupId = selectedGroupId.value;
    if (title.isEmpty || priority == null || groupId == null) return false;

    isSaving.value = true;
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
      AppSnackbar.success(
        'snack_task_created'.tr,
        'snack_task_created_msg'.trParams({'title': title}),
      );
      return true;
    } catch (e) {
      AppSnackbar.error(
        'snack_error'.tr,
        AppSnackbar.parseApiError(e, fallback: 'snack_task_create_fail'.tr),
      );
      return false;
    } finally {
      isSaving.value = false;
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

    isSaving.value = true;
    try {
      await _updateTaskItem(updated);
      await fetchTasks();
      AppSnackbar.success(
        'snack_task_updated'.tr,
        'snack_task_updated_msg'.trParams({'title': title}),
      );
      return true;
    } catch (e) {
      AppSnackbar.error(
        'snack_error'.tr,
        AppSnackbar.parseApiError(e, fallback: 'snack_task_update_fail'.tr),
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteTask(TaskItem taskItem) async {
    try {
      await _deleteTaskItem(taskItem);
      allTasks.removeWhere((t) => t.id == taskItem.id);
      _applyStatusFilter();
      AppSnackbar.success(
        'snack_task_deleted'.tr,
        'snack_task_deleted_msg'.trParams({'title': taskItem.title}),
      );
    } catch (e) {
      AppSnackbar.error(
        'snack_error'.tr,
        AppSnackbar.parseApiError(e, fallback: 'snack_task_delete_fail'.tr),
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
  void resetForm(List<Group> groups) {
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
}
