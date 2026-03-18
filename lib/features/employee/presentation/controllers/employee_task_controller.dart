import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_task_statuses_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/assign_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/fetch_task_item.usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/update_task_item_status_usecase.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/task_comment_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/task_member_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/task_progress_controller.dart';

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

  // ── State ────────────────────────────────────────────────────────────────

  /// Raw API result — full group task list.
  final RxList<TaskItem> allTasks = <TaskItem>[].obs;

  /// My tasks only — excludes pending and tasks not assigned to me.
  /// Passed to the filter bar so chip counts reflect only my tasks.
  final RxList<TaskItem> myTasks = <TaskItem>[].obs;

  final RxList<TaskStatusLookup> taskStatus = <TaskStatusLookup>[].obs;

  /// Active status filter chip.
  final RxString filterStatus = 'All'.obs;
  final Rxn<int> filterStatusId = Rxn<int>();

  final RxString searchQuery = ''.obs;
  final Rxn<DateTime> taskSelectedDate = Rxn<DateTime>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// Loading state for the detail-sheet primary action button.
  final RxBool actionLoading = false.obs;

  // ── Computed ─────────────────────────────────────────────────────────────

  String? get currentEmployeeId =>
      Get.find<AuthController>().profile.value?.employeeId;

  /// Tasks shown in the list — my tasks with optional status filter applied.
  List<TaskItem> get filteredTasks {
    if (filterStatusId.value == null) return myTasks.toList();
    return myTasks.where((t) => t.status.id == filterStatusId.value).toList();
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();

    final now = DateTime.now();
    taskSelectedDate.value = DateTime(now.year, now.month, now.day);

    fetchTasks();
    fetchStatuses();

    // Rebuild myTasks whenever allTasks changes.
    ever(allTasks, (_) => _refreshMyTasks());

    // Status chip change → re-filter client-side.
    ever(filterStatusId, (_) => myTasks.refresh());

    // Search input → debounced API call.
    debounce(
      searchQuery,
      (_) => fetchTasks(),
      time: const Duration(milliseconds: 500),
    );

    // Re-fetch when navigating back to My Tasks tab (index 1).
    ever(Get.find<NavigationController>().selectedIndex, (int idx) {
      if (idx == 1) fetchTasks();
    });
  }

  // ── Private helpers ──────────────────────────────────────────────────────

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

  bool _isPending(TaskItem t) =>
      t.status.name.toLowerCase().replaceAll(' ', '') == 'pending';

  void _refreshMyTasks() {
    final myId = currentEmployeeId;
    myTasks.assignAll(
      allTasks.where((t) => !_isPending(t) && t.assignedToId == myId),
    );
  }

  // ── Data fetching ────────────────────────────────────────────────────────

  Future<void> fetchTasks() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _fetchTaskItems(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        groupId: _employeeGroupId,
        SelectedDate: taskSelectedDate.value,
      );
      allTasks.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStatuses() async {
    try {
      final result = await _fetchStatuses();
      if (result.isNotEmpty) taskStatus.assignAll(result);
    } catch (_) {}
  }

  // ── Selection ────────────────────────────────────────────────────────────

  void selectTaskDate(DateTime? date) {
    taskSelectedDate.value = date != null
        ? DateTime(date.year, date.month, date.day)
        : null;
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

  // ── Detail sheet ─────────────────────────────────────────────────────────

  void prepareTaskDetail(String taskId) {
    actionLoading.value = false;
    final memberCtrl = Get.find<TaskMemberController>();
    final commentCtrl = Get.find<TaskCommentController>();
    final progressCtrl = Get.find<TaskProgressController>();
    memberCtrl.currentTaskMembers.clear();
    commentCtrl.currentTaskComments.clear();
    progressCtrl.currentTaskProgresses.clear();
    memberCtrl.fetchTaskMembers(taskId);
    memberCtrl.fetchGroupEmployees();
    commentCtrl.fetchTaskComments(taskId);
    progressCtrl.fetchTaskProgresses(taskId);
  }

  // ── Status transitions ───────────────────────────────────────────────────

  Future<bool> _runTransition(
    TaskItem task,
    TaskStatusLookup newStatus,
    Future<void> Function() apiWork,
  ) async {
    try {
      await apiWork();
      await fetchTasks();
      selectStatus(newStatus);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> acceptTask(TaskItem task) async {
    final employeeId = currentEmployeeId;
    if (employeeId == null || employeeId.isEmpty) {
      errorMessage.value = 'Employee profile not found.';
      return false;
    }
    if (task.allowedTransitions.isEmpty) {
      errorMessage.value = 'No available transition for this task.';
      return false;
    }
    final newStatus = task.allowedTransitions.first;
    return _runTransition(task, newStatus, () async {
      await _assignTask(task.id, employeeId);
      await _updateStatus(task.id, newStatus.id);
    });
  }

  /// Generic transition — uses the status directly from [task.allowedTransitions].
  Future<bool> transitionTask(TaskItem task, TaskStatusLookup newStatus) async {
    return _runTransition(
      task,
      newStatus,
      () => _updateStatus(task.id, newStatus.id),
    );
  }
}
