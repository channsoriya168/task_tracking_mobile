import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/lookup/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/lookup/domain/usecases/fetch_task_statuses_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/fetch_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/fetch_task_item_by_id_usecase.dart';

class ManagerDashboardController extends GetxController {
  final FetchTaskItemsUsecase _fetchTaskItems;
  final FetchTaskItemByIdUsecase _fetchTaskItemById;
  final FetchTaskStatusesUsecase _fetchStatuses;

  ManagerDashboardController(
    this._fetchTaskItems,
    this._fetchTaskItemById,
    this._fetchStatuses,
  );

  final RxList<TaskItem> tasks = <TaskItem>[].obs;
  final RxList<TaskItem> allTasks = <TaskItem>[].obs;
  final RxList<TaskStatusLookup> taskStatus = <TaskStatusLookup>[].obs;

  final RxString filterStatus = 'All'.obs;
  final Rxn<int> filterStatusId = Rxn<int>();
  final RxString searchQuery = ''.obs;

  /// Selected day on the week calendar.
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();

  /// Date filter chip shown above the task list.
  final Rxn<DateTime> dashboardDateFilter = Rxn<DateTime>();

  final RxBool isLoading = false.obs;

  List<TaskItem> get filteredTasks => tasks.toList();

  /// Tasks grouped by created-at bucket: "Today", "Yesterday", or a
  /// short date string for older entries. Preserves insertion order.
  Map<String, List<TaskItem>> get groupedTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final map = <String, List<TaskItem>>{};
    for (final task in tasks) {
      final String label;
      if (task.createdAt == null) {
        label = 'Unknown Date';
      } else {
        final d = DateTime(
          task.createdAt!.year,
          task.createdAt!.month,
          task.createdAt!.day,
        );
        if (d == today) {
          label = 'Today';
        } else if (d == yesterday) {
          label = 'Yesterday';
        } else {
          label = '${months[d.month - 1]} ${d.day}, ${d.year}';
        }
      }
      map.putIfAbsent(label, () => []).add(task);
    }
    return map;
  }

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    selectedDate.value = DateTime(now.year, now.month, now.day);

    fetchTasks();
    fetchStatuses();

    ever(filterStatusId, (_) => _applyStatusFilter());
    debounce(
      searchQuery,
      (_) => fetchTasks(),
      time: const Duration(milliseconds: 500),
    );
  }

  Future<TaskItem?> fetchTaskById(String id) async {
    try {
      return await _fetchTaskItemById(id);
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchTasks() async {
    isLoading.value = true;
    try {
      final result = await _fetchTaskItems(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        SelectedDate: selectedDate.value,
      );
      allTasks.assignAll(result);
      _applyStatusFilter();
    } catch (_) {
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

  void selectDate(DateTime? date) {
    selectedDate.value = date ?? DateTime.now();
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
}
