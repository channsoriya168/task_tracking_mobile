import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_task_statuses_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/assign_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/fetch_task_item.usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/update_task_item_status_usecase.dart';
import 'dart:developer' as developer;

class EmployeeTaskController extends GetxController {
  final FetchTaskItemsUsecase _fetchTaskItems;
  final FetchTaskStatusesUsecase _fetchStatuses;
  final AssignTaskItemUsecase _assignTask;
  final UpdateTaskItemStatusUsecase _updateStatus;

  EmployeeTaskController(
    this._fetchTaskItems,
    this._fetchStatuses,
    this._assignTask,
    this._updateStatus,
  );

  /// Full unfiltered list — used for chip counts and client-side status filter.
  final RxList<TaskItem> allTasks = <TaskItem>[].obs;
  final RxList<TaskStatusLookup> taskStatus = <TaskStatusLookup>[].obs;

  /// Status filter — applied client-side so counts stay correct.
  final RxString filterStatus = 'All'.obs;
  final Rxn<int> filterStatusId = Rxn<int>();

  final RxString searchQuery = ''.obs;

  /// Selected day from the week calendar.
  final Rxn<DateTime> taskSelectedDate = Rxn<DateTime>();

  /// Due-date range sent to the API.
  final Rxn<DateTime> filterDueDateFrom = Rxn<DateTime>();
  final Rxn<DateTime> filterDueDateTo = Rxn<DateTime>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// Status-filtered view of allTasks for the task list.
  List<TaskItem> get filteredTasks {
    if (filterStatusId.value == null) return allTasks.toList();
    return allTasks.where((t) => t.status.id == filterStatusId.value).toList();
  }

  /// Count for each chip — always from allTasks so all chips stay accurate.
  int countByStatus(String statusName) {
    if (statusName == 'All') return allTasks.length;
    return allTasks
        .where((t) => t.status.name.toLowerCase() == statusName.toLowerCase())
        .length;
  }

  /// Extract the first task-group ID from the logged-in employee's profile.
  String? get _employeeGroupId {
    final profile = Get.find<AuthController>().profile.value;
    if (profile == null || profile.taskGroups.isEmpty) return null;
    final first = profile.taskGroups.first;
    if (first is Map<String, dynamic>) {
      return first['id'] as String? ??
          first['groupId'] as String? ??
          first['taskGroupId'] as String?;
    }
    if (first is String) return first;
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    // Default date filter to today.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    taskSelectedDate.value = today;
    filterDueDateFrom.value = today;
    filterDueDateTo.value = DateTime(now.year, now.month, now.day, 23, 59, 59);

    fetchTasks();
    fetchStatuses();

    // Status change → just re-filter client-side (no API call needed).
    ever(filterStatusId, (_) => allTasks.refresh());

    // Date/search change → re-fetch from API.
    debounce(
      searchQuery,
      (_) => fetchTasks(),
      time: const Duration(milliseconds: 500),
    );
  }

  /// Fetches all tasks for the current group/date/search — NO status filter
  /// so that every chip always has the correct count.
  Future<void> fetchTasks() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _fetchTaskItems(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        groupId: _employeeGroupId,
        SelectedDate: filterDueDateFrom.value,
        // statusId intentionally omitted — filtered client-side
      );
      allTasks.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

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

  void selectStatus(TaskStatusLookup? status) {
    if (status == null) {
      filterStatus.value = 'All';
      filterStatusId.value = null;
    } else {
      filterStatus.value = status.name;
      filterStatusId.value = status.id;
    }
  }

  Future<void> fetchStatuses() async {
    try {
      final result = await _fetchStatuses();
      if (result.isNotEmpty) taskStatus.assignAll(result);
    } catch (_) {}
  }

  String? get _employeeId =>
      Get.find<AuthController>().profile.value?.employeeId;

  /// Assigns the task to the current employee and sets status to InProgress.
  Future<bool> acceptTask(TaskItem task) async {
    final employeeId = _employeeId;
    if (employeeId == null) return false;

    final inProgressId = taskStatus
        .firstWhereOrNull((s) => s.name.toLowerCase() == 'assigned')
        ?.id;
    if (inProgressId == null) return false;

    try {
      await _assignTask(task.id, employeeId);
      await _updateStatus(task.id, inProgressId);
      await fetchTasks();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }
}
