import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:task_tracking_mobile/features/employee/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_member.dart';
import 'package:task_tracking_mobile/features/employee/domain/usecases/fetch_employees_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/add_task_member_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/fetch_task_members_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/remove_task_member_usecase.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/employee_picker_sheet.dart';

class EmployeeTaskMemberController extends GetxController {
  final FetchTaskMembersUsecase _fetchTaskMembers;
  final AddTaskMemberUsecase _addTaskMember;
  final RemoveTaskMemberUsecase _removeTaskMember;
  final FetchEmployeesUsecase _fetchEmployees;

  EmployeeTaskMemberController(
    this._fetchTaskMembers,
    this._addTaskMember,
    this._removeTaskMember,
    this._fetchEmployees,
  );

  final RxList<TaskMember> currentTaskMembers = <TaskMember>[].obs;
  final RxBool membersLoading = false.obs;
  final RxList<Employee> groupEmployees = <Employee>[].obs;

  String? get currentEmployeeId =>
      Get.find<ProfileController>().profile.value?.employeeId;

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

  // ── Member action handlers ────────────────────────────────────────────────

  Future<void> handleAddMember(
    String taskId,
    List<TaskMember> currentMembers,
    bool isDark,
  ) async {
    if (groupEmployees.isEmpty) await fetchGroupEmployees();

    final addedIds = currentMembers.map((m) => m.employeeId).toSet();
    final available = groupEmployees
        .where((e) => !addedIds.contains(e.id) && e.id != currentEmployeeId)
        .toList();

    final selected = await Get.bottomSheet<Employee>(
      EmployeePickerSheet(employees: available, isDark: isDark),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
    if (selected == null) return;

    final ok = await _confirmDialog(
      title: 'member_add_title'.tr,
      content: 'member_add_confirm'.trParams({'name': selected.fullName}),
      confirmLabel: 'action_add'.tr,
      isDark: isDark,
    );
    if (ok == true) await addMember(taskId, selected.id);
  }

  Future<void> handleRemoveMember(
    String taskId,
    TaskMember member,
    bool isDark,
  ) async {
    final ok = await _confirmDialog(
      title: 'member_remove_title'.tr,
      content: 'member_remove_confirm'.trParams({'name': member.employeeName}),
      confirmLabel: 'action_remove'.tr,
      confirmColor: Colors.red,
      isDark: isDark,
    );
    if (ok == true) await removeMember(taskId, member.id);
  }

  Future<bool?> _confirmDialog({
    required String title,
    required String content,
    required String confirmLabel,
    required bool isDark,
    Color confirmColor = kPrimary,
  }) => Get.dialog<bool>(
    AlertDialog(
      backgroundColor: isDark ? kCardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : kTextDark,
        ),
      ),
      content: Text(
        content,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white70 : kTextMuted,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(
            'Cancel',
            style: TextStyle(color: isDark ? Colors.white54 : kTextMuted),
          ),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
