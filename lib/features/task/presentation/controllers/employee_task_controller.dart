import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:task_tracking_mobile/features/main/presentation/controllers/navigation_controller.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/lookup/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/lookup/domain/usecases/fetch_task_statuses_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/fetch_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/update_task_item_status_usecase.dart';
import 'package:task_tracking_mobile/features/dashboard/controllers/employee_home_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/employee_task_member_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/employee_task_comment_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/employee_task_progress_controller.dart';

class EmployeeTaskController extends GetxController {
  final FetchTaskItemsUsecase _fetchTaskItems;
  final FetchTaskStatusesUsecase _fetchStatuses;
  final UpdateTaskItemStatusUsecase _updateStatus;

  EmployeeTaskController(
    this._fetchTaskItems,
    this._fetchStatuses,
    this._updateStatus,
  );

  // ── State ────────────────────────────────────────────────────────────────

  final RxList<TaskItem> allTasks = <TaskItem>[].obs;
  final RxList<TaskItem> myTasks = <TaskItem>[].obs;
  final RxList<TaskStatusLookup> taskStatus = <TaskStatusLookup>[].obs;

  final RxString filterStatus = 'All'.obs;
  final Rxn<int> filterStatusId = Rxn<int>();
  final RxString searchQuery = ''.obs;
  final Rxn<DateTime> taskSelectedDate = Rxn<DateTime>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool actionLoading = false.obs;

  // ── Detail sheet UI state ────────────────────────────────────────────────
  final RxInt selectedTab = 0.obs;
  final Rxn<int> transitionLoadingId = Rxn<int>();

  // ── Computed ─────────────────────────────────────────────────────────────

  String? get currentEmployeeId =>
      Get.find<ProfileController>().profile.value?.employeeId;

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

    ever(allTasks, (_) => _refreshMyTasks());
    ever(filterStatusId, (_) => myTasks.refresh());

    debounce(
      searchQuery,
      (_) => fetchTasks(),
      time: const Duration(milliseconds: 500),
    );

    ever(Get.find<NavigationController>().selectedIndex, (int idx) {
      if (idx == 1) fetchTasks();
    });

    // Auto-refresh when internet is restored.
    ever(Get.find<NetworkController>().connectionStatus, (status) {
      if (status == ConnectionStatus.reconnected) {
        fetchTasks();
        fetchStatuses();
      }
    });
  }

  // ── Private helpers ──────────────────────────────────────────────────────

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

  void prepareTaskDetail(String taskId, {int initialTab = 0}) {
    actionLoading.value = false;
    selectedTab.value = initialTab;
    transitionLoadingId.value = null;
    final memberCtrl = Get.find<EmployeeTaskMemberController>();
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

  // ── Detail actions ───────────────────────────────────────────────────────

  Future<void> handleAccept(TaskItem task) async {
    if (transitionLoadingId.value != null) return;
    transitionLoadingId.value = -1;
    final success = await Get.find<EmployeeHomeController>().acceptTask(task);
    transitionLoadingId.value = null;
    if (success) {
      Get.back();
      AppSnackbar.success(
        'snack_task_accepted'.tr,
        'snack_task_accepted_msg'.trParams({'title': task.title}),
      );
      Get.find<NavigationController>().changePage(1);
    }
  }

  Future<void> handleTransition(
    TaskItem task,
    TaskStatusLookup newStatus,
  ) async {
    if (transitionLoadingId.value != null) return;
    transitionLoadingId.value = newStatus.id;
    final success = await transitionTask(task, newStatus);
    transitionLoadingId.value = null;
    if (success) {
      Get.back();
      AppSnackbar.update(
        'snack_status_updated'.tr,
        'snack_status_updated_msg'.trParams({
          'status': newStatus.localizedName,
        }),
      );
    }
  }

  // ── Status transitions ───────────────────────────────────────────────────

  Future<bool> transitionTask(TaskItem task, TaskStatusLookup newStatus) async {
    try {
      await _updateStatus(task.id, newStatus.id);
      await fetchTasks();
      if (Get.isRegistered<EmployeeHomeController>()) {
        await Get.find<EmployeeHomeController>().fetchTasks();
      }
      selectStatus(newStatus);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }
}
