import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/lookup/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/lookup/domain/usecases/fetch_task_statuses_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/assign_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/fetch_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/update_task_item_status_usecase.dart';

class HomeController extends GetxController {
  final FetchTaskItemsUsecase _fetchTaskItems;
  final FetchTaskStatusesUsecase _fetchStatuses;
  final AssignTaskItemUsecase _assignTask;
  final UpdateTaskItemStatusUsecase _updateStatus;

  HomeController(
    this._fetchTaskItems,
    this._fetchStatuses,
    this._assignTask,
    this._updateStatus,
  );

  // ── State ────────────────────────────────────────────────────────────────

  final RxList<TaskItem> allTasks = <TaskItem>[].obs;
  final RxList<TaskStatusLookup> taskStatus = <TaskStatusLookup>[].obs;
  final RxBool isLoading = false.obs;

  final RxString filterStatus = 'All'.obs;
  final Rxn<int> filterStatusId = Rxn<int>();
  final RxString searchQuery = ''.obs;
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();

  // ── Computed ─────────────────────────────────────────────────────────────

  String get employeeName =>
      Get.find<ProfileController>().profile.value?.fullName ?? '';

  /// All group tasks filtered by status and search query.
  /// Date filtering is handled by the API — no client-side date re-filter.
  List<TaskItem> get filteredTasks {
    var tasks = allTasks.toList();

    if (filterStatusId.value != null) {
      tasks = tasks.where((t) => t.status.id == filterStatusId.value).toList();
    }

    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      tasks = tasks.where((t) => t.title.toLowerCase().contains(q)).toList();
    }

    return tasks;
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    selectedDate.value = DateTime(now.year, now.month, now.day);
    fetchTasks();
    fetchStatuses();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  String? get _employeeGroupId {
    final profile = Get.find<ProfileController>().profile.value;
    if (profile == null || profile.groups.isEmpty) return null;
    final first = profile.groups.first;
    if (first is Map<String, dynamic>) {
      return first['id'] as String? ??
          first['groupId'] as String? ??
          first['taskGroupId'] as String?;
    }
    if (first is String) return first;
    return null;
  }

  // ── Data fetching ─────────────────────────────────────────────────────────

  Future<void> fetchTasks() async {
    isLoading.value = true;
    try {
      final result = await _fetchTaskItems(
        groupId: _employeeGroupId,
        SelectedDate: selectedDate.value,
      );
      allTasks.assignAll(result);
    } catch (_) {
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

  // ── Actions ──────────────────────────────────────────────────────────────

  void selectDate(DateTime? date) {
    selectedDate.value = date != null
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

  // ── Accept task ───────────────────────────────────────────────────────────

  Future<bool> acceptTask(TaskItem task) async {
    final employeeId =
        Get.find<ProfileController>().profile.value?.employeeId ?? '';
    if (employeeId.isEmpty || task.allowedTransitions.isEmpty) return false;
    final newStatus = task.allowedTransitions.first;
    try {
      await _assignTask(task.id, employeeId);
      await _updateStatus(task.id, newStatus.id);
      await fetchTasks();
      return true;
    } catch (_) {
      return false;
    }
  }
}
