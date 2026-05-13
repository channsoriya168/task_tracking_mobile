import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/core/widgets/no_internet_dialog.dart';
import 'package:task_tracking_mobile/core/utils/network_utils.dart';
import 'package:task_tracking_mobile/core/utils/validators.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_validator.dart';
import 'package:task_tracking_mobile/features/employee/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/group/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/lookup/domain/entities/lookup_gender.dart';
import 'package:task_tracking_mobile/features/employee/domain/repositories/employee_repository.dart';
import 'package:task_tracking_mobile/features/lookup/domain/repositories/lookup_repository.dart';
import 'package:task_tracking_mobile/features/employee/domain/usecases/create_employee_usecase.dart';
import 'package:task_tracking_mobile/features/employee/domain/usecases/update_employee_usecase.dart';
import 'package:task_tracking_mobile/features/employee/domain/usecases/reset_employee_password_usecase.dart';
import 'package:task_tracking_mobile/features/group/presentation/controllers/group_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/employee_form_dialog.dart';
import 'package:task_tracking_mobile/features/group/presentation/widgets/group_dialog.dart';

class EmployeeController extends GetxController {
  EmployeeController(
    this._repository,
    this._createEmployee,
    this._updateEmployee,
    this._resetPasswordUsecase,
    this._lookupRepository,
  );

  final EmployeeRepository _repository;
  final CreateEmployeeUsecase _createEmployee;
  final UpdateEmployeeUsecase _updateEmployee;
  final ResetEmployeePasswordUsecase _resetPasswordUsecase;
  final LookupRepository _lookupRepository;

  // ── List state ────────────────────────────────────────────────
  final RxList<Employee> employees = <Employee>[].obs;
  final RxList<Employee> allEmployees = <Employee>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isOfflineDialogOpen = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedTaskGroupId = ''.obs;

  RxList<Group> get groups => Get.find<GroupController>().groups;

  // ── Gender lookup ──────────────────────────────────────────────
  final RxList<LookupGender> genders = <LookupGender>[].obs;

  Future<void> fetchGenders() async {
    try {
      genders.value = await _lookupRepository.fetchGenders();
    } catch (e) {
      debugPrint('[EmployeeController] fetchGenders error: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
    fetchGenders();
    ever(selectedTaskGroupId, (_) => fetchEmployees());
    ever(Get.find<NetworkController>().connectionStatus, (status) {
      if (status == ConnectionStatus.reconnected) {
        fetchEmployees();
        if (genders.isEmpty) fetchGenders();
      }
    });
  }

  Future<void> fetchEmployees() async {
    try {
      isLoading.value = true;
      final groupId = selectedTaskGroupId.value.isNotEmpty
          ? selectedTaskGroupId.value
          : null;
      employees.value = await _repository.fetchEmployees(groupId: groupId);
      if (groupId == null) allEmployees.assignAll(employees);
    } catch (e) {
      throw Exception(e);
    } finally {
      isLoading.value = false;
    }
  }

  List<Employee> get filteredEmployees {
    var list = employees.toList();
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
      AppSnackbar.delete('snack_emp_deleted'.tr, 'snack_emp_deleted_msg'.tr);
    } catch (e) {
      AppSnackbar.error('snack_error'.tr, e.toString());
    }
  }

  // ── Form state ────────────────────────────────────────────────
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController placeCtrl = TextEditingController();

  final RxString selectedRole = 'Employee'.obs;
  final Rxn<String> selectedGenderId = Rxn<String>();

  final Rx<DateTime?> formDob = Rx(null);
  final Rxn<String> selectedGroupId = Rxn<String>();
  final Rxn<XFile> profileImage = Rxn<XFile>();
  final RxBool isSaving = false.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  final RxBool isEditMode = false.obs;
  String? _editingId;
  String? existingImageUrl;
  final RxBool removeProfileImage = false.obs;

  // ── Reset password form ───────────────────────────────────────
  final TextEditingController resetPasswordCtrl = TextEditingController();
  final TextEditingController resetConfirmPasswordCtrl =
      TextEditingController();
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
  bool get canSave {
    if (isSaving.value) return false;
    if (isEditMode.value) return true;
    return formDob.value != null && selectedGroupId.value != null;
  }

  // ── Task Group dialog ─────────────────────────────────────────
  Future<void> openTaskGroupDialog(BuildContext context) async {
    final tgCtrl = Get.find<GroupController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final before = tgCtrl.groups.map((g) => g.id).toSet();

    await showGroupDialog(context, tgCtrl, isDark);

    final added = tgCtrl.groups.where((g) => !before.contains(g.id)).toList();
    if (added.isNotEmpty) {
      selectedGroupId.value = added.first.id;
    }
  }

  // ── Dialog ────────────────────────────────────────────────────
  Future<void> showCreateDialog([String? preselectedGroupId]) async {
    _resetForm();
    selectedGroupId.value = preselectedGroupId;
    await _showFormSheet();
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
    selectedGenderId.value = employee.genderId;
    formDob.value = employee.dateOfBirth;
    selectedGroupId.value = employee.groups.isNotEmpty
        ? employee.groups.first.groupId
        : null;
    await _showFormSheet();
  }

  Future<void> _showFormSheet() async {
    Worker? offlineWorker;
    offlineWorker = ever(Get.find<NetworkController>().isConnected, (
      connected,
    ) {
      if (!connected) {
        offlineWorker?.dispose();
        Get.back();
        isOfflineDialogOpen.value = true;
        showNoInternetDialog(
          isDark: Get.isDarkMode,
          redirectCount: 1,
        ).then((_) => isOfflineDialogOpen.value = false);
      }
    });

    await Get.bottomSheet(
      EmployeeFormDialog(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    offlineWorker.dispose();
  }

  void _resetForm() {
    nameCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
    placeCtrl.clear();
    formDob.value = null;
    selectedGroupId.value = null;
    selectedGenderId.value = null;
    selectedRole.value = 'Employee';
    profileImage.value = null;
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
      AppSnackbar.success('snack_reset_pwd'.tr, 'snack_pwd_changed'.tr);
    } catch (e) {
      AppSnackbar.error('snack_reset_pwd'.tr, AppSnackbar.parseApiError(e));
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

    final errors = EmployeeValidator.validateCreate(
      name: name,
      email: email,
      phone: phone,
      dob: formDob.value,
      genderId: selectedGenderId.value,
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
        phone: phone.isEmpty ? null : Validators.toE164(phone),
        placeOfBirth: placeCtrl.text.trim().isEmpty
            ? null
            : placeCtrl.text.trim(),
        dateOfBirth: formDob.value,
        genderId: selectedGenderId.value,
        groupIds: selectedGroupId.value != null
            ? [selectedGroupId.value!]
            : null,
        profileImagePath: profileImage.value?.path,
        role: selectedRole.value,
      );
      Get.back();
      AppSnackbar.success('snack_emp_added'.tr, 'snack_emp_added_msg'.tr);
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
    final role = selectedRole.value;

    final errors = EmployeeValidator.validateEdit(
      name: name,
      email: email,
      phone: phone,
      dob: formDob.value,
      genderId: selectedGenderId.value,
      groupId: selectedGroupId.value,
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
        genderId: selectedGenderId.value,
        groupIds: selectedGroupId.value != null
            ? [selectedGroupId.value!]
            : null,
        profileImagePath: profileImage.value?.path,
        removeProfileImage: removeProfileImage.value,
        role: role,
      );
      Get.back();
      await fetchEmployees();
      AppSnackbar.update('snack_emp_updated'.tr, 'snack_emp_updated_msg'.tr);
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
    phoneCtrl.dispose();
    placeCtrl.dispose();
    resetPasswordCtrl.dispose();
    resetConfirmPasswordCtrl.dispose();
    super.onClose();
  }
}
