import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_tracking_mobile/app/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/create_employee_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/update_employee_usecase.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_employee_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/admin_employee_form_dialog.dart';

class AdminEmployeeFormController extends GetxController {
  final CreateEmployeeUsecase _createEmployee;
  final UpdateEmployeeUsecase _updateEmployee;

  AdminEmployeeFormController(this._createEmployee, this._updateEmployee);

  // ── Form fields ───────────────────────────────────────────────
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final placeCtrl = TextEditingController();

  final Rx<DateTime?> formDob = Rx(null);
  final RxList<String> selectedGroupIds = <String>[].obs;
  final Rxn<XFile> profileImage = Rxn<XFile>();
  final RxBool isSaving = false.obs;
  final RxBool showPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  // ── Edit mode ─────────────────────────────────────────────────
  final RxBool isEditMode = false.obs;
  String? _editingId;
  String? existingImageUrl;
  final RxBool removeProfileImage = false.obs;

  /// Converts local Khmer format (0XXXXXXXX) to +855 for the API body.
  String _toE164(String phone) {
    if (phone.startsWith('0')) return '+855${phone.substring(1)}';
    return phone;
  }

  // ── Image ─────────────────────────────────────────────────────
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) profileImage.value = picked;
  }

  // ── Dialog ────────────────────────────────────────────────────
  void showCreateDialog(bool isDark) {
    _resetForm();
    Get.bottomSheet(
      AdminEmployeeFormDialog(controller: this),
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
    final p = employee.phone ?? '';
    phoneCtrl.text = p.startsWith('+855') ? '0${p.substring(4)}' : p;
    placeCtrl.text = employee.placeOfBirth ?? '';
    formDob.value = employee.dateOfBirth;
    if (employee.taskGroups.isNotEmpty) {
      selectedGroupIds.assignAll([employee.taskGroups.first.groupId]);
    }
    await Get.bottomSheet(
      AdminEmployeeFormDialog(controller: this),
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
    selectedGroupIds.clear();
    profileImage.value = null;
    showPassword.value = false;
    showConfirmPassword.value = false;
    fieldErrors.clear();
    isEditMode.value = false;
    _editingId = null;
    existingImageUrl = null;
    removeProfileImage.value = false;
  }

  void toggleGroup(String groupId) {
    if (selectedGroupIds.contains(groupId)) {
      selectedGroupIds.remove(groupId);
    } else {
      selectedGroupIds
        ..clear()
        ..add(groupId);
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
    )) {
      return;
    }

    isSaving.value = true;
    try {
      await _createEmployee(
        fullName: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        phone: _toE164(phone),
        placeOfBirth:
            placeCtrl.text.trim().isEmpty ? null : placeCtrl.text.trim(),
        dateOfBirth: formDob.value,
        groupIds: selectedGroupIds.isEmpty ? null : selectedGroupIds.toList(),
        profileImagePath: profileImage.value?.path,
      );
      Get.back();
      Get.find<AdminEmployeeController>().fetchEmployees();
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
        email: email,
        phone: phone.isEmpty ? null : _toE164(phone),
        placeOfBirth:
            placeCtrl.text.trim().isEmpty ? null : placeCtrl.text.trim(),
        dateOfBirth: formDob.value,
        groupIds: selectedGroupIds.isEmpty ? null : selectedGroupIds.toList(),
        profileImagePath: profileImage.value?.path,
        removeProfileImage: removeProfileImage.value,
      );
      Get.back();
      await Get.find<AdminEmployeeController>().fetchEmployees();
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
    if (name.isEmpty) errors['fullName'] = 'Full name is required.';
    if (email.isEmpty) {
      errors['email'] = 'Email is required.';
    } else if (!GetUtils.isEmail(email)) {
      errors['email'] = 'Enter a valid email address.';
    }
    if (phone.isNotEmpty && !RegExp(r'^(0\d{8,9}|\+855\d{8,9})$').hasMatch(phone)) {
      errors['phone'] = 'Invalid number. e.g. 010111111 or +85510111111';
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

    if (name.isEmpty) errors['fullName'] = 'Full name is required.';

    if (email.isEmpty) {
      errors['email'] = 'Email is required.';
    } else if (!GetUtils.isEmail(email)) {
      errors['email'] = 'Enter a valid email address.';
    }

    if (phone.isEmpty) {
      errors['phone'] = 'Phone is required.';
    } else if (!RegExp(r'^(0\d{8,9}|\+855\d{8,9})$').hasMatch(phone)) {
      errors['phone'] = 'Invalid number. e.g. 010111111 or +85510111111';
    }

    if (password.isEmpty) {
      errors['password'] = 'Password is required.';
    } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors['password'] = 'Must contain at least one uppercase letter.';
    } else if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors['password'] = 'Must contain at least one lowercase letter.';
    } else if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      errors['password'] = 'Must contain at least one special character.';
    }

    if (confirmPassword.isEmpty) {
      errors['confirmPassword'] = 'Please confirm your password.';
    } else if (password != confirmPassword) {
      errors['confirmPassword'] = 'Passwords do not match.';
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
    super.onClose();
  }
}
