import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_tracking_mobile/app/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/app/utils/validators.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/employee_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/create_employee_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/update_employee_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/reset_employee_password_usecase.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/task_group_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_form_dialog.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task_group/task_group_dialog.dart';
import 'package:task_tracking_mobile/features/employee/data/models/task_model.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/task_controller.dart';

class EmployeeController extends GetxController {
  EmployeeController(
    this._repository,
    this._createEmployee,
    this._updateEmployee,
    this._resetPasswordUsecase,
  );

  final EmployeeRepository _repository;
  final CreateEmployeeUsecase _createEmployee;
  final UpdateEmployeeUsecase _updateEmployee;
  final ResetEmployeePasswordUsecase _resetPasswordUsecase;

  // ── List state ────────────────────────────────────────────────
  final RxList<Employee> employees = <Employee>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedTaskGroupId = ''.obs;

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
      employees.value = await _repository.fetchEmployees();
    } catch (_) {
      AppSnackbar.error('Error', 'Failed to load employees.');
    } finally {
      isLoading.value = false;
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

  TaskGroup? taskGroupForEmployee(Employee emp) {
    if (emp.taskGroups.isEmpty) return null;
    final g = emp.taskGroups.first;
    return findTaskGroup(g.groupId) ??
        TaskGroup(id: g.groupId, name: g.groupName, color: g.groupColor);
  }

  int employeeCountByTaskGroup(String groupId) => employees
      .where((e) => e.taskGroups.any((g) => g.groupId == groupId))
      .length;

  Future<void> deleteEmployee(String id) async {
    try {
      await _repository.deleteEmployee(id);
      employees.removeWhere((e) => e.id == id);
      AppSnackbar.delete('Employee Deleted', 'Employee has been removed.');
    } catch (e) {
      AppSnackbar.error('Error', e.toString());
    }
  }

  List<TaskModel> tasksForEmployee(String employeeId) {
    try {
      final taskCtrl = Get.find<TaskController>();
      return taskCtrl.tasks.where((t) => t.assignedToId == employeeId).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Form state ────────────────────────────────────────────────
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final placeCtrl = TextEditingController();

  final Rx<DateTime?> formDob = Rx(null);
  final Rxn<String> selectedGroupId = Rxn<String>();
  final Rxn<XFile> profileImage = Rxn<XFile>();
  final RxBool isSaving = false.obs;
  final RxBool showPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  final RxBool isEditMode = false.obs;
  String? _editingId;
  String? existingImageUrl;
  final RxBool removeProfileImage = false.obs;

  // ── Reset password form ───────────────────────────────────────
  final resetPasswordCtrl = TextEditingController();
  final resetConfirmPasswordCtrl = TextEditingController();
  final RxBool showResetPassword = false.obs;
  final RxBool showResetConfirmPassword = false.obs;
  final RxBool isResettingPassword = false.obs;
  final RxMap<String, String> resetPasswordErrors = <String, String>{}.obs;

  // ── Image ─────────────────────────────────────────────────────
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) profileImage.value = picked;
  }

  // ── Form validity (reactive) ──────────────────────────────────
  bool get canSave => formDob.value != null && selectedGroupId.value != null;

  // ── Task Group dialog ─────────────────────────────────────────
  Future<void> openTaskGroupDialog(BuildContext context) async {
    final tgCtrl = Get.find<TaskGroupController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final before = tgCtrl.taskGroups.map((g) => g.id).toSet();

    await showTaskGroupDialog(context, tgCtrl, isDark);

    final added = tgCtrl.taskGroups
        .where((g) => !before.contains(g.id))
        .toList();
    if (added.isNotEmpty) {
      selectedGroupId.value = added.first.id;
    }
  }

  // ── Dialog ────────────────────────────────────────────────────
  Future<void> showCreateDialog([String? preselectedGroupId]) async {
    _resetForm();
    selectedGroupId.value = preselectedGroupId;
    await Get.bottomSheet(
      ManagerEmployeeFormDialog(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> showEditDialog(Employee employee) async {
    _resetForm();
    isEditMode.value = true;
    _editingId = employee.id;
    existingImageUrl = employee.profileImageUrl;
    nameCtrl.text = employee.fullName;
    emailCtrl.text = employee.email;
    phoneCtrl.text = _toLocalDigits(employee.phone ?? '');
    placeCtrl.text = employee.placeOfBirth ?? '';
    formDob.value = employee.dateOfBirth;
    selectedGroupId.value = employee.taskGroups.isNotEmpty
        ? employee.taskGroups.first.groupId
        : null;
    await Get.bottomSheet(
      ManagerEmployeeFormDialog(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _resetForm() {
    nameCtrl.clear();
    emailCtrl.clear();
    passwordCtrl.clear();
    confirmPasswordCtrl.clear();
    phoneCtrl.clear();
    placeCtrl.clear();
    formDob.value = null;
    selectedGroupId.value = null;
    profileImage.value = null;
    showPassword.value = false;
    showConfirmPassword.value = false;
    fieldErrors.clear();
    isEditMode.value = false;
    _editingId = null;
    existingImageUrl = null;
    removeProfileImage.value = false;
  }

  /// Strips +855 / 855 / leading 0 so only local digits are shown in the field.
  static String _toLocalDigits(String phone) {
    if (phone.startsWith('+855')) return phone.substring(4);
    if (phone.startsWith('855')) return phone.substring(3);
    if (phone.startsWith('0')) return phone.substring(1);
    return phone;
  }

  void selectGroup(String groupId) {
    selectedGroupId.value = selectedGroupId.value == groupId ? null : groupId;
    if (selectedGroupId.value != null) {
      fieldErrors.remove('taskGroup');
    }
  }

  // ── Reset Password ────────────────────────────────────────────
  void openResetPasswordForm() {
    resetPasswordCtrl.clear();
    resetConfirmPasswordCtrl.clear();
    showResetPassword.value = false;
    showResetConfirmPassword.value = false;
    resetPasswordErrors.clear();
  }

  Future<void> resetPasswordForEmployee(String employeeId) async {
    resetPasswordErrors.clear();
    final newPass = resetPasswordCtrl.text;
    final confirmPass = resetConfirmPasswordCtrl.text;

    final errors = <String, String>{};
    final pwErr = Validators.strongPassword(newPass);
    if (pwErr != null) errors['newPassword'] = pwErr;
    if (confirmPass.isEmpty) {
      errors['confirmPassword'] = 'Please confirm the password.';
    } else if (newPass != confirmPass) {
      errors['confirmPassword'] = 'Passwords do not match.';
    }
    if (errors.isNotEmpty) {
      resetPasswordErrors.assignAll(errors);
      return;
    }

    isResettingPassword.value = true;
    try {
      await _resetPasswordUsecase(
        employeeId: employeeId,
        newPassword: newPass,
        confirmNewPassword: confirmPass,
      );
      resetPasswordCtrl.clear();
      resetConfirmPasswordCtrl.clear();
      Get.back();
      AppSnackbar.success(
        'Password Reset',
        'Password has been reset successfully.',
      );
    } catch (e) {
      AppSnackbar.error('Reset Password', AppSnackbar.parseApiError(e));
    } finally {
      isResettingPassword.value = false;
    }
  }

  // ── Save ──────────────────────────────────────────────────────
  Future<void> save() async {
    if (isEditMode.value) {
      await _saveEdit();
    } else {
      await _saveCreate();
    }
  }

  Future<void> _saveCreate() async {
    fieldErrors.clear();
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final password = passwordCtrl.text;
    final confirmPassword = confirmPasswordCtrl.text;

    if (!_validateCreate(
      name: name,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
    ))
      return;

    isSaving.value = true;
    try {
      await _createEmployee(
        fullName: name,
        email: email.isEmpty ? null : email,
        password: password,
        confirmPassword: confirmPassword,
        phone: phone.isEmpty ? null : Validators.toE164(phone),
        placeOfBirth: placeCtrl.text.trim().isEmpty
            ? null
            : placeCtrl.text.trim(),
        dateOfBirth: formDob.value,
        groupIds: selectedGroupId.value != null
            ? [selectedGroupId.value!]
            : null,
        profileImagePath: profileImage.value?.path,
      );
      Get.back();
      AppSnackbar.success('Employee Added', 'New employee has been created.');
      await fetchEmployees();
    } catch (e) {
      _handleApiError(e, label: 'Create Employee');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _saveEdit() async {
    fieldErrors.clear();
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final phone = phoneCtrl.text.trim();

    if (!_validateEdit(name: name, email: email, phone: phone)) return;

    isSaving.value = true;
    try {
      await _updateEmployee(
        _editingId!,
        fullName: name,
        email: email.isEmpty ? null : email,
        phone: phone.isEmpty ? null : Validators.toE164(phone),
        placeOfBirth: placeCtrl.text.trim().isEmpty
            ? null
            : placeCtrl.text.trim(),
        dateOfBirth: formDob.value,
        groupIds: selectedGroupId.value != null
            ? [selectedGroupId.value!]
            : null,
        profileImagePath: profileImage.value?.path,
        removeProfileImage: removeProfileImage.value,
      );
      Get.back();
      await fetchEmployees();
      AppSnackbar.update('Employee Updated', 'Changes have been saved.');
    } catch (e) {
      _handleApiError(e, label: 'Edit Employee');
    } finally {
      isSaving.value = false;
    }
  }

  // ── Validation ────────────────────────────────────────────────
  bool _validateEdit({
    required String name,
    required String email,
    required String phone,
  }) {
    final errors = <String, String>{};
    if (Validators.required(name, label: 'Full name') != null) {
      errors['fullName'] = Validators.required(name, label: 'Full name')!;
    }
    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      errors['email'] = 'Enter a valid email address.';
    }
    if (phone.isNotEmpty) {
      final phoneErr = Validators.phone(phone);
      if (phoneErr != null) errors['phone'] = phoneErr;
    }
    if (formDob.value == null) {
      errors['dob'] = 'Date of birth is required.';
    }
    if (selectedGroupId.value == null) {
      errors['taskGroup'] = 'Please select a task group.';
    }
    if (errors.isNotEmpty) {
      fieldErrors.assignAll(errors);
      return false;
    }
    return true;
  }

  bool _validateCreate({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) {
    final errors = <String, String>{};
    if (Validators.required(name, label: 'Full name') != null) {
      errors['fullName'] = Validators.required(name, label: 'Full name')!;
    }
    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      errors['email'] = 'Enter a valid email address.';
    }
    final phoneErr = Validators.phone(phone);
    if (phoneErr != null) errors['phone'] = phoneErr;
    final pwErr = Validators.strongPassword(password);
    if (pwErr != null) errors['password'] = pwErr;
    if (confirmPassword.isEmpty) {
      errors['confirmPassword'] = 'Please confirm your password.';
    } else if (password != confirmPassword) {
      errors['confirmPassword'] = 'Passwords do not match.';
    }
    if (formDob.value == null) {
      errors['dob'] = 'Date of birth is required.';
    }
    if (selectedGroupId.value == null) {
      errors['taskGroup'] = 'Please select a task group.';
    }
    if (errors.isNotEmpty) {
      fieldErrors.assignAll(errors);
      return false;
    }
    return true;
  }

  // ── API error mapping ─────────────────────────────────────────
  static const _fieldKeyMap = {
    'FullName': 'fullName',
    'Email': 'email',
    'Phone': 'phone',
    'Password': 'password',
    'ConfirmPassword': 'confirmPassword',
    'PlaceOfBirth': 'placeOfBirth',
    'DateOfBirth': 'dateOfBirth',
  };

  void _handleApiError(Object e, {String label = 'Employee'}) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['errors'] is Map) {
        final mapped = <String, String>{};
        (data['errors'] as Map).forEach((key, value) {
          final localKey = _fieldKeyMap[key] ?? key.toString();
          final msgs = value is List ? value : [value];
          if (msgs.isNotEmpty) mapped[localKey] = msgs.first.toString();
        });
        if (mapped.isNotEmpty) {
          fieldErrors.assignAll(mapped);
          return;
        }
      }
    }
    AppSnackbar.error(label, AppSnackbar.parseApiError(e));
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    phoneCtrl.dispose();
    placeCtrl.dispose();
    resetPasswordCtrl.dispose();
    resetConfirmPasswordCtrl.dispose();
    super.onClose();
  }
}
