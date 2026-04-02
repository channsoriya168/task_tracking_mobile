import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_tracking_mobile/app/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/app/utils/validators.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_validator.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/employee_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/create_employee_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/update_employee_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/reset_employee_password_usecase.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/group_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_form_dialog.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/group/group_dialog.dart';

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

  Future<void> deleteEmployee(String id) async {
    try {
      await _repository.deleteEmployee(id);
      employees.removeWhere((e) => e.id == id);
      AppSnackbar.delete('Employee Deleted', 'Employee has been removed.');
    } catch (e) {
      AppSnackbar.error('Error', e.toString());
    }
  }

  // ── Form state ────────────────────────────────────────────────
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final placeCtrl = TextEditingController();

  final RxString selectedRole = 'Employee'.obs;

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
  // Create: require DOB + group before enabling submit.
  // Edit: always allow submit — validator shows inline errors for missing fields.
  bool get canSave {
    if (isSaving.value) return false;
    if (isEditMode.value) return true;
    return formDob.value != null && selectedGroupId.value != null;
  }

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
    selectedRole.value = employee.role ?? 'Employee';
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
    selectedRole.value = 'Employee';
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

    final errors = EmployeeValidator.validateCreate(
      name: name,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
      dob: formDob.value,
      groupId: selectedGroupId.value,
    );
    if (errors.isNotEmpty) {
      fieldErrors.assignAll(errors);
      return;
    }

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
        role: selectedRole.value,
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
    final password = passwordCtrl.text;
    final confirmPassword = confirmPasswordCtrl.text;
    final role = selectedRole.value;

    final errors = EmployeeValidator.validateEdit(
      name: name,
      email: email,
      phone: phone,
      dob: formDob.value,
      groupId: selectedGroupId.value,
      password: password,
      confirmPassword: confirmPassword,
    );
    if (errors.isNotEmpty) {
      fieldErrors.assignAll(errors);
      return;
    }

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
        password: password.isEmpty ? null : password,
        confirmPassword: confirmPassword.isEmpty ? null : confirmPassword,
        role: role,
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

  // ── API error mapping ─────────────────────────────────────────
  static const _fieldKeyMap = {
    'FullName': 'fullName',
    'Email': 'email',
    'Phone': 'phone',
    'Password': 'password',
    'ConfirmPassword': 'confirmPassword',
    'PlaceOfBirth': 'placeOfBirth',
    'DateOfBirth': 'dateOfBirth',
    'Role': 'role',
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
