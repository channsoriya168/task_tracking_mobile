import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_member.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_employees_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_task_statuses_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_progress.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/add_task_member_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/assign_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/create_task_progress_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/delete_task_progress_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/update_task_progress_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/fetch_task_item.usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/fetch_task_members_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/fetch_task_progresses_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/remove_task_member_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/update_task_item_status_usecase.dart';

class EmployeeTaskController extends GetxController {
  final FetchTaskItemsUsecase _fetchTaskItems;
  final FetchTaskStatusesUsecase _fetchStatuses;
  final AssignTaskItemUsecase _assignTask;
  final UpdateTaskItemStatusUsecase _updateStatus;
  final FetchEmployeesUsecase _fetchEmployees;
  final FetchTaskMembersUsecase _fetchTaskMembers;
  final AddTaskMemberUsecase _addTaskMember;
  final RemoveTaskMemberUsecase _removeTaskMember;
  final FetchTaskProgressesUsecase _fetchTaskProgresses;
  final CreateTaskProgressUsecase _createTaskProgress;
  final UpdateTaskProgressUsecase _updateTaskProgress;
  final DeleteTaskProgressUsecase _deleteTaskProgress;

  EmployeeTaskController(
    this._fetchTaskItems,
    this._fetchStatuses,
    this._assignTask,
    this._updateStatus,
    this._fetchEmployees,
    this._fetchTaskMembers,
    this._addTaskMember,
    this._removeTaskMember,
    this._fetchTaskProgresses,
    this._createTaskProgress,
    this._updateTaskProgress,
    this._deleteTaskProgress,
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

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// Members of the currently-open task.
  final RxList<TaskMember> currentTaskMembers = <TaskMember>[].obs;
  final RxBool membersLoading = false.obs;

  /// Employees in the current group (for the add-member picker).
  final RxList<Employee> groupEmployees = <Employee>[].obs;

  /// Progresses of the currently-open task.
  final RxList<TaskProgress> currentTaskProgresses = <TaskProgress>[].obs;
  final RxBool progressLoading = false.obs;
  final RxString progressError = ''.obs;

  /// Loading state for the detail-sheet primary action button.
  final RxBool actionLoading = false.obs;

  /// Call before opening the task detail sheet to reset state and pre-fetch data.
  void prepareTaskDetail(
    String taskId, {
    bool showMembers = false,
    bool showProgress = false,
  }) {
    actionLoading.value = false;
    if (showMembers || showProgress) {
      fetchTaskMembers(taskId);
      fetchGroupEmployees();
    }
    if (showProgress) {
      fetchTaskProgresses(taskId);
    }
  }

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

  /// The logged-in employee's ID — used to gate the "In Progress" button.
  String? get currentEmployeeId =>
      Get.find<AuthController>().profile.value?.employeeId;

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
        SelectedDate: taskSelectedDate.value,
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
    taskSelectedDate.value =
        date != null ? DateTime(date.year, date.month, date.day) : null;
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

  /// Sets the task status to "In Progress".
  Future<bool> setInProgress(TaskItem task) async {
    final inProgressStatus = taskStatus.firstWhereOrNull((s) {
      final n = s.name.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
      return n == 'inprogress';
    });
    if (inProgressStatus == null) {
      errorMessage.value = 'In Progress status not found. Please try again.';
      return false;
    }
    try {
      await _updateStatus(task.id, inProgressStatus.id);
      selectStatus(inProgressStatus);
      await fetchTasks();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  /// Accepts the task by assigning it to the current employee and setting status to Assigned.
  Future<bool> acceptTask(TaskItem task) async {
    final employeeId = currentEmployeeId;
    if (employeeId == null || employeeId.isEmpty) {
      errorMessage.value = 'Employee profile not found.';
      return false;
    }

    final assignedStatus = taskStatus
        .firstWhereOrNull((s) => s.name.toLowerCase() == 'assigned');
    if (assignedStatus == null) {
      errorMessage.value = 'Assigned status not found. Please try again.';
      return false;
    }

    try {
      await _assignTask(task.id, employeeId);
      await _updateStatus(task.id, assignedStatus.id);
      selectStatus(assignedStatus);
      await fetchTasks();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  // ── Member management ────────────────────────────────────────────────────

  Future<void> fetchTaskMembers(String taskItemId) async {
    membersLoading.value = true;
    try {
      final result = await _fetchTaskMembers(taskItemId);
      currentTaskMembers.assignAll(result);
    } catch (_) {
      currentTaskMembers.clear();
    } finally {
      membersLoading.value = false;
    }
  }

  Future<void> fetchGroupEmployees() async {
    try {
      final result = await _fetchEmployees(groupId: _employeeGroupId);
      groupEmployees.assignAll(result);
    } catch (_) {
      groupEmployees.clear();
    }
  }

  Future<bool> addMember(String taskItemId, String employeeId) async {
    try {
      await _addTaskMember(taskItemId, employeeId);
      await fetchTaskMembers(taskItemId);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> removeMember(String taskItemId, String memberId) async {
    try {
      await _removeTaskMember(taskItemId, memberId);
      await fetchTaskMembers(taskItemId);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  // ── Progress management ──────────────────────────────────────────────────

  Future<void> fetchTaskProgresses(String taskItemId) async {
    progressLoading.value = true;
    progressError.value = '';
    try {
      final result = await _fetchTaskProgresses(taskItemId);
      currentTaskProgresses.assignAll(result);
    } catch (e) {
      progressError.value = e.toString();
    } finally {
      progressLoading.value = false;
    }
  }

  Future<bool> createProgress(
    String taskItemId, {
    required int progressPercentage,
    required DateTime loggedAt,
    String? notes,
    double? hoursWorked,
  }) async {
    try {
      await _createTaskProgress(
        taskItemId,
        progressPercentage: progressPercentage,
        loggedAt: loggedAt,
        notes: notes,
        hoursWorked: hoursWorked,
      );
      await fetchTaskProgresses(taskItemId);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> updateProgress(
    String taskItemId,
    String progressId, {
    required int progressPercentage,
    required DateTime loggedAt,
    required String notes,
    double? hoursWorked,
  }) async {
    try {
      await _updateTaskProgress(
        taskItemId,
        progressId,
        progressPercentage: progressPercentage,
        loggedAt: loggedAt,
        notes: notes,
        hoursWorked: hoursWorked,
      );
      await fetchTaskProgresses(taskItemId);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> deleteProgress(String taskItemId, String progressId) async {
    try {
      await _deleteTaskProgress(taskItemId, progressId);
      await fetchTaskProgresses(taskItemId);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  /// Moves the task to "Completed" status.
  Future<bool> setCompleted(TaskItem task) async {
    final completedStatus = taskStatus.firstWhereOrNull((s) {
      final n = s.name.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
      return n == 'completed' || n == 'complete' || n == 'done';
    });
    if (completedStatus == null) {
      errorMessage.value = 'Completed status not found. Please try again.';
      return false;
    }
    try {
      await _updateStatus(task.id, completedStatus.id);
      selectStatus(completedStatus);
      await fetchTasks();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  /// Moves the task to "In Review" status.
  Future<bool> setInReview(TaskItem task) async {
    final inReviewStatus = taskStatus.firstWhereOrNull((s) {
      final n = s.name.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
      return n == 'inreview';
    });
    if (inReviewStatus == null) {
      errorMessage.value = 'In Review status not found. Please try again.';
      return false;
    }
    try {
      await _updateStatus(task.id, inReviewStatus.id);
      selectStatus(inReviewStatus);
      await fetchTasks();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }
}
