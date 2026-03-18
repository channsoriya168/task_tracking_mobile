import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_task_statuses_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/fetch_task_item.usecase.dart';

class HomeController extends GetxController {
  final FetchTaskItemsUsecase _fetchTaskItems;
  final FetchTaskStatusesUsecase _fetchStatuses;

  HomeController(this._fetchTaskItems, this._fetchStatuses);

  // ── State ────────────────────────────────────────────────────────────────

  final RxList<TaskItem> allTasks = <TaskItem>[].obs;
  final RxList<TaskStatusLookup> taskStatus = <TaskStatusLookup>[].obs;
  final RxBool isLoading = false.obs;

  final RxString filterStatus = 'All'.obs;
  final Rxn<int> filterStatusId = Rxn<int>();
  final RxString searchQuery = ''.obs;
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();

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

  // ── Computed ─────────────────────────────────────────────────────────────

  List<TaskItem> get filteredTasks {
    var tasks = allTasks.toList();

    final sel = selectedDate.value;
    if (sel != null) {
      tasks = tasks.where((t) {
        final d = t.dueDate ?? t.startDate ?? t.createdAt;
        if (d == null) return false;
        return d.year == sel.year && d.month == sel.month && d.day == sel.day;
      }).toList();
    }

    if (filterStatusId.value != null) {
      tasks = tasks.where((t) => t.status.id == filterStatusId.value).toList();
    }

    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      tasks = tasks.where((t) => t.title.toLowerCase().contains(q)).toList();
    }

    return tasks;
  }

  /// Tasks grouped by status name (respects date/status/search filters).
  Map<String, List<TaskItem>> get groupedTasks {
    final Map<String, List<TaskItem>> groups = {};
    for (final task in filteredTasks) {
      groups.putIfAbsent(task.status.name, () => []).add(task);
    }
    return groups;
  }

  /// All tasks grouped by task group name (no date/status filter).
  Map<String, List<TaskItem>> get tasksByGroup {
    final Map<String, List<TaskItem>> groups = {};
    for (final task in allTasks) {
      final key = task.groupName ?? 'No Group';
      groups.putIfAbsent(key, () => []).add(task);
    }
    return groups;
  }

  /// { groupName → { statusName → count } }
  Map<String, Map<String, int>> get statusCountByGroup {
    final result = <String, Map<String, int>>{};
    for (final entry in tasksByGroup.entries) {
      final counts = <String, int>{};
      for (final task in entry.value) {
        counts[task.status.name] = (counts[task.status.name] ?? 0) + 1;
      }
      result[entry.key] = counts;
    }
    return result;
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
}
