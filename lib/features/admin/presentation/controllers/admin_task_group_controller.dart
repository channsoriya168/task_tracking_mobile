import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/create_task_group_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/delete_task_group_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/get_all_task_groups_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/update_task_group_usecase.dart';

class AdminTaskGroupController extends GetxController {
  final GetAllTaskGroupsUseCase _getAll;
  final CreateTaskGroupUseCase _create;
  final UpdateTaskGroupUseCase _update;
  final DeleteTaskGroupUseCase _delete;

  AdminTaskGroupController(
    this._getAll,
    this._create,
    this._update,
    this._delete,
  );

  // ── State ─────────────────────────────────────────────────
  final RxList<TaskGroup> taskGroups = <TaskGroup>[].obs;
  final RxBool isLoading = false.obs;

  // ── Form ──────────────────────────────────────────────────
  static const Color kDefaultColor = Color(0xFF6C63FF);
  final nameCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final Rxn<Color> selectedColor = Rxn<Color>(kDefaultColor);

  @override
  void onInit() {
    super.onInit();
    fetchTaskGroups();
  }

  Future<void> fetchTaskGroups() async {
    isLoading.value = true;
    try {
      taskGroups.assignAll(await _getAll());
    } catch (_) {
      AppSnackbar.error('Task Groups', 'Failed to load task groups.');
    } finally {
      isLoading.value = false;
    }
  }

  void initForm(TaskGroup? existing) {
    nameCtrl.text = existing?.name ?? '';
    descriptionCtrl.text = existing?.description ?? '';
    selectedColor.value = existing?.color ?? kDefaultColor;
  }

  // ── CRUD ──────────────────────────────────────────────────
  Future<bool> createTaskGroup({
    required String name,
    Color? color,
    String? description,
  }) async {
    try {
      final created = await _create(
        name: name,
        color: _toHex(color),
        description: description,
      );
      taskGroups.add(created);
      AppSnackbar.success(
        'Task Group Added',
        '"${created.name}" has been created.',
      );
      return true;
    } catch (_) {
      AppSnackbar.error('Task Groups', 'Failed to create task group.');
      return false;
    }
  }

  Future<bool> updateTaskGroup(
    String id, {
    required String name,
    Color? color,
    String? description,
  }) async {
    try {
      final updated = await _update(
        id,
        name: name,
        color: _toHex(color),
        description: description,
      );
      final i = taskGroups.indexWhere((g) => g.id == id);
      if (i != -1) taskGroups[i] = updated;
      AppSnackbar.update(
        'Task Group Updated',
        '"${updated.name}" has been updated.',
      );
      return true;
    } catch (_) {
      AppSnackbar.error('Task Groups', 'Failed to update task group.');
      return false;
    }
  }

  Future<void> deleteTaskGroup(String id) async {
    final group = taskGroups.firstWhereOrNull((g) => g.id == id);
    if (group == null) return;
    try {
      await _delete(id);
      taskGroups.removeWhere((g) => g.id == id);
      AppSnackbar.delete(
        'Task Group Deleted',
        '"${group.name}" has been removed.',
      );
    } catch (_) {
      AppSnackbar.error('Task Groups', 'Failed to delete task group.');
    }
  }

  // ── Helpers ───────────────────────────────────────────────
  String? _toHex(Color? color) {
    if (color == null) return null;
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descriptionCtrl.dispose();
    super.onClose();
  }
}
