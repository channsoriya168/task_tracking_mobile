import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/features/employee/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/group/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/group/domain/usecases/create_group_usecase.dart';
import 'package:task_tracking_mobile/features/group/domain/usecases/delete_group_usecase.dart';
import 'package:task_tracking_mobile/features/group/domain/usecases/get_all_groups_usecase.dart';
import 'package:task_tracking_mobile/features/group/domain/usecases/update_group_usecase.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_controller.dart';

class GroupController extends GetxController {
  final RxList<Group> groups = <Group>[].obs;
  final GetAllGroupsUseCase _getAllGroups;
  final CreateGroupUseCase _createGroup;
  final UpdateGroupUseCase _updateGroup;
  final DeleteGroupUseCase _deleteGroup;

  GroupController(
    this._getAllGroups,
    this._createGroup,
    this._updateGroup,
    this._deleteGroup,
  );

  static const Color kDefaultTaskGroupColor = Color(0xFF6C63FF);
  final TextEditingController nameEditingController = TextEditingController();
  final TextEditingController descriptionEditingController =
      TextEditingController();
  final Rxn<Color> selectedColor = Rxn<Color>(kDefaultTaskGroupColor);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isOfflineDialogOpen = false.obs;
  final RxBool showNameError = false.obs;
  final RxBool showColorError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGroups();
    ever(Get.find<NetworkController>().connectionStatus, (status) {
      if (status == ConnectionStatus.reconnected) fetchGroups();
    });
  }

  Future<void> fetchGroups() async {
    try {
      isLoading.value = true;
      groups.assignAll(await _getAllGroups());
    } catch (_) {
      final offline = !Get.find<NetworkController>().isConnected.value;
      if (!offline) AppSnackbar.error('snack_label'.tr, 'snack_group_load_fail'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  void initGroupForm(Group? existing) {
    isSaving.value = false;
    showNameError.value = false;
    showColorError.value = false;
    nameEditingController.text = existing?.name ?? '';
    descriptionEditingController.text = existing?.description ?? '';
    selectedColor.value = existing?.color ?? kDefaultTaskGroupColor;
  }

  @override
  void onClose() {
    nameEditingController.dispose();
    descriptionEditingController.dispose();
    super.onClose();
  }

  Future<bool> createGroup() async {
    isSaving.value = true;
    try {
      final taskGroup = await _createGroup(
        name: nameEditingController.text.trim(),
        color: _toHexColor(selectedColor.value),
        description: descriptionEditingController.text.trim(),
      );
      groups.add(taskGroup);
      AppSnackbar.success(
        'snack_group_added'.tr,
        'snack_group_added_msg'.trParams({'name': taskGroup.name}),
      );
      return true;
    } catch (_) {
      isSaving.value = false;
      AppSnackbar.error('snack_label'.tr, 'snack_group_create_fail'.tr);
      return false;
    }
  }

  Future<void> updateGroup(Group updated) async {
    final i = groups.indexWhere((p) => p.id == updated.id);
    if (i == -1) return;

    isSaving.value = true;
    try {
      final result = await _updateGroup(
        updated.id,
        name: updated.name,
        color: _toHexColor(updated.color),
        description: updated.description,
      );
      groups[i] = result;
      AppSnackbar.update(
        'snack_group_updated'.tr,
        'snack_group_updated_msg'.trParams({'name': result.name}),
      );
    } catch (_) {
      isSaving.value = false;
      AppSnackbar.error('snack_label'.tr, 'snack_group_update_fail'.tr);
    }
  }

  Future<void> deleteGroup(String id) async {
    var groupName = 'the group';
    for (final group in groups) {
      if (group.id == id) {
        groupName = group.name;
        break;
      }
    }

    final employeeCount = employeeCountByGroup(id);
    if (employeeCount > 0) {
      AppSnackbar.error(
        'snack_group_delete_blocked'.tr,
        'snack_group_delete_has_employees'.trParams({
          'count': employeeCount.toString(),
        }),
      );
      return;
    }

    try {
      await _deleteGroup(id);
      await fetchGroups();
      AppSnackbar.delete(
        'snack_group_deleted'.tr,
        'snack_group_deleted_msg'.trParams({'name': groupName}),
      );
    } catch (_) {
      AppSnackbar.error('snack_label'.tr, 'snack_group_delete_fail'.tr);
    }
  }

  // ── Employee helpers ──────────────────────────────────────────
  List<Employee> employeesByGroup(String groupId) =>
      Get.find<EmployeeController>().filteredEmployees;

  int employeeCountByGroup(String groupId) => Get.find<EmployeeController>()
      .allEmployees
      .where((e) => e.groups.any((g) => g.groupId == groupId))
      .length;

  String? _toHexColor(Color? color) {
    if (color == null) return null;
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
