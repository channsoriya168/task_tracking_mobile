import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_member.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_employees_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/add_task_member_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/fetch_task_members_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/remove_task_member_usecase.dart';

class TaskMemberController extends GetxController {
  final FetchTaskMembersUsecase _fetchTaskMembers;
  final AddTaskMemberUsecase _addTaskMember;
  final RemoveTaskMemberUsecase _removeTaskMember;
  final FetchEmployeesUsecase _fetchEmployees;

  TaskMemberController(
    this._fetchTaskMembers,
    this._addTaskMember,
    this._removeTaskMember,
    this._fetchEmployees,
  );

  final RxList<TaskMember> currentTaskMembers = <TaskMember>[].obs;
  final RxBool membersLoading = false.obs;
  final RxList<Employee> groupEmployees = <Employee>[].obs;

  String? get currentEmployeeId =>
      Get.find<AuthController>().profile.value?.employeeId;

  String? get _employeeGroupId {
    final profile = Get.find<AuthController>().profile.value;
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
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeMember(String taskItemId, String memberId) async {
    try {
      await _removeTaskMember(taskItemId, memberId);
      await fetchTaskMembers(taskItemId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
