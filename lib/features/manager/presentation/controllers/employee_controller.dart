import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/employee_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/pick_and_compress_image_usecase.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/image_picker_bottom_sheet.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/task_group_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_dialog.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/task_group_dialog.dart';
import 'package:task_tracking_mobile/features/employee/data/models/task_model.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/task_controller.dart';

class EmployeeController extends GetxController {
  EmployeeController(this._repository);

  final EmployeeRepository _repository;

  final RxList<Employee> employees = <Employee>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedTaskGroupId = ''.obs;
  final PickAndCompressImageUseCase pickImage = Get.find();

  // Track the employee being edited
  Employee? existing;

  RxList<TaskGroup> get taskGroups =>
      Get.find<TaskGroupController>().taskGroups;

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    try {
      isLoading.value = true;
      final list = await _repository.fetchEmployees();
      employees.value = list;
    } catch (_) {
      Get.snackbar('Error', 'Failed to load employees');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickFromGallery() async {
    final result = await pickImage(ImageSource.gallery);
    if (result != null) formImagePath.value = result.path;
  }

  Future<void> pickFromCamera() async {
    final result = await pickImage(ImageSource.camera);
    if (result != null) formImagePath.value = result.path;
  }

  void showImagePickerOptions([bool isDark = false]) {
    ImagePickerBottomSheet.show(
      isDark: isDark,
      onCameraTap: pickFromCamera,
      onGalleryTap: pickFromGallery,
    );
  }

  Future<void> onOpenTaskGroupDialog(BuildContext context) async {
    final posCtrl = Get.find<TaskGroupController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final before = posCtrl.taskGroups.map((p) => p.id).toSet();

    await showTaskGroupDialog(context, posCtrl, isDark);

    final added = posCtrl.taskGroups
        .where((p) => !before.contains(p.id))
        .toList();
    if (added.isNotEmpty) {
      if (!formGroupIds.contains(added.first.id)) {
        formGroupIds.add(added.first.id);
      }
    }
  }

  List<Employee> get filteredEmployees {
    var list = employees.toList();
    if (selectedTaskGroupId.value.isNotEmpty) {
      list = list
          .where(
            (e) =>
                e.taskGroups.any((g) => g.groupId == selectedTaskGroupId.value),
          )
          .toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((e) {
        return e.fullName.toLowerCase().contains(q) ||
            e.email.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  List<Employee> employeesByTaskGroup(String groupId) {
    return filteredEmployees
        .where((e) => e.taskGroups.any((g) => g.groupId == groupId))
        .toList();
  }

  TaskGroup? findTaskGroup(String id) {
    try {
      return taskGroups.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns a [TaskGroup] built from the employee's first inline task group,
  /// falling back to the TaskGroupController lookup.
  TaskGroup? taskGroupForEmployee(Employee emp) {
    if (emp.taskGroups.isEmpty) return null;
    final g = emp.taskGroups.first;
    return findTaskGroup(g.groupId) ??
        TaskGroup(id: g.groupId, name: g.groupName, color: g.groupColor);
  }

  int employeeCountByTaskGroup(String groupId) => employees
      .where((e) => e.taskGroups.any((g) => g.groupId == groupId))
      .length;

  // ── Dialog form state ──────────────────────────────────────────
  final Rx<String?> formImagePath = Rx(null);
  final RxList<String> formGroupIds = <String>[].obs;
  final Rx<DateTime?> formDob = Rx(null);

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final placeCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  // Password visibility toggles
  final formPasswordVisible = false.obs;
  final formConfirmPasswordVisible = false.obs;

  // Reactive mirrors used solely for form-valid computation
  final _rName = ''.obs;
  final _rPhone = ''.obs;
  final _rPassword = ''.obs;
  final _rConfirmPassword = ''.obs;

  bool get isFormValid {
    final base = _rName.value.isNotEmpty &&
        _rPhone.value.isNotEmpty &&
        formDob.value != null &&
        formGroupIds.isNotEmpty;
    if (existing == null) {
      return base &&
          _rPassword.value.isNotEmpty &&
          _rConfirmPassword.value.isNotEmpty;
    }
    return base;
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    placeCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }

  void initDialogForm(Employee? existing, String? preselectedTaskGroupId) {
    this.existing = existing;
    formImagePath.value = existing?.profileImageUrl;
    formGroupIds.value = existing != null
        ? existing.taskGroups.map((g) => g.groupId).toList()
        : (preselectedTaskGroupId != null ? [preselectedTaskGroupId] : []);
    formDob.value = existing?.dateOfBirth;
    nameCtrl.text = existing?.fullName ?? '';
    emailCtrl.text = existing?.email ?? '';
    phoneCtrl.text = existing?.phone ?? '';
    placeCtrl.text = existing?.placeOfBirth ?? '';
    passwordCtrl.clear();
    confirmPasswordCtrl.clear();
    formPasswordVisible.value = false;
    formConfirmPasswordVisible.value = false;

    // Sync reactive mirrors and attach listeners
    _rName.value = nameCtrl.text.trim();
    _rPhone.value = phoneCtrl.text.trim();
    _rPassword.value = '';
    _rConfirmPassword.value = '';

    nameCtrl.addListener(() => _rName.value = nameCtrl.text.trim());
    phoneCtrl.addListener(() => _rPhone.value = phoneCtrl.text.trim());
    passwordCtrl.addListener(() => _rPassword.value = passwordCtrl.text.trim());
    confirmPasswordCtrl.addListener(
      () => _rConfirmPassword.value = confirmPasswordCtrl.text.trim(),
    );
  }

  void showDialog(
    bool isDark, [
    Employee? existing,
    String? preselectedTaskGroupId,
  ]) {
    initDialogForm(existing, preselectedTaskGroupId);
    Get.bottomSheet(
      EmployeeDialogSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> saveEmployee() async {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim();
    final phone = phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim();
    final placeOfBirth = placeCtrl.text.trim().isEmpty
        ? null
        : placeCtrl.text.trim();
    final groupIds = formGroupIds.toList();

    if (name.isEmpty ||
        phoneCtrl.text.trim().isEmpty ||
        formDob.value == null ||
        groupIds.isEmpty) return;

    final imagePath = formImagePath.value;
    final isLocalPath = imagePath != null && !imagePath.startsWith('http');

    try {
      isLoading.value = true;
      if (existing == null) {
        final password = passwordCtrl.text.trim();
        final confirmPassword = confirmPasswordCtrl.text.trim();
        if (password.isEmpty || password != confirmPassword) return;

        final created = await _repository.createEmployee(
          fullName: name,
          email: email,
          password: password,
          confirmPassword: confirmPassword,
          phone: phone,
          placeOfBirth: placeOfBirth,
          dateOfBirth: formDob.value,
          groupIds: groupIds,
          profileImagePath: isLocalPath ? imagePath : null,
        );
        employees.add(created);
      } else {
        final hadImage = existing!.profileImageUrl != null;
        final removeImage = hadImage && imagePath == null;

        final updated = await _repository.updateEmployee(
          existing!.id,
          fullName: name,
          email: email,
          phone: phone,
          placeOfBirth: placeOfBirth,
          dateOfBirth: formDob.value,
          groupIds: groupIds,
          profileImagePath: isLocalPath ? imagePath : null,
          removeProfileImage: removeImage,
        );
        final i = employees.indexWhere((e) => e.id == updated.id);
        if (i != -1) employees[i] = updated;
      }
      Get.back();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteEmployee(String id) async {
    try {
      await _repository.deleteEmployee(id);
      employees.removeWhere((e) => e.id == id);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // ── Tasks ──────────────────────────────────────────────────────
  List<TaskModel> tasksForEmployee(String employeeId) {
    try {
      final taskCtrl = Get.find<TaskController>();
      return taskCtrl.tasks.where((t) => t.assignedToId == employeeId).toList();
    } catch (_) {
      return [];
    }
  }
}
