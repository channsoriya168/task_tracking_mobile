import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/core/utils/validators.dart';
import 'package:task_tracking_mobile/core/widgets/no_internet_dialog.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_validator.dart';
import 'package:task_tracking_mobile/features/employee/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/group/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/lookup/domain/entities/lookup_gender.dart';
import 'package:task_tracking_mobile/features/employee/domain/repositories/employee_repository.dart';
import 'package:task_tracking_mobile/features/lookup/domain/repositories/lookup_repository.dart';
import 'package:task_tracking_mobile/features/employee/domain/usecases/create_employee_usecase.dart';
import 'package:task_tracking_mobile/features/employee/domain/usecases/update_employee_usecase.dart';
import 'package:task_tracking_mobile/features/group/presentation/controllers/group_controller.dart';

class EmployeeController extends GetxController {
  EmployeeController(
    this._repository,
    this._createEmployee,
    this._updateEmployee,
    this._lookupRepository,
  );

  final EmployeeRepository _repository;
  final CreateEmployeeUsecase _createEmployee;
  final UpdateEmployeeUsecase _updateEmployee;
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
      allEmployees.removeWhere((e) => e.id == id);
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
  String? existingImageUrl;
  final RxBool removeProfileImage = false.obs;

  String? _editingId;

  // ── Form lifecycle ────────────────────────────────────────────
  void prepareForCreate() {
    _editingId = null;
    isEditMode.value = false;
    nameCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
    placeCtrl.clear();
    formDob.value = null;
    selectedGenderId.value = null;
    selectedGroupId.value = null;
    profileImage.value = null;
    existingImageUrl = null;
    removeProfileImage.value = false;
    selectedRole.value = 'Employee';
    fieldErrors.clear();
    isSaving.value = false;
  }

  void prepareForEdit(Employee emp) {
    _editingId = emp.id;
    isEditMode.value = true;
    nameCtrl.text = emp.fullName;
    emailCtrl.text = emp.email;
    phoneCtrl.text = emp.phone != null ? _toLocalDigits(emp.phone!) : '';
    placeCtrl.text = emp.placeOfBirth ?? '';
    formDob.value = emp.dateOfBirth;
    selectedGenderId.value = emp.genderId;
    selectedGroupId.value = emp.groups.isNotEmpty
        ? emp.groups.first.groupId
        : null;
    profileImage.value = null;
    existingImageUrl = emp.profileImageUrl;
    removeProfileImage.value = false;
    selectedRole.value = emp.role ?? 'Employee';
    fieldErrors.clear();
    isSaving.value = false;
  }

  // ── Save (create or update) ───────────────────────────────────
  Future<void> save() async {
    final phone = _toLocalDigits(phoneCtrl.text.trim());
    final errors = isEditMode.value
        ? EmployeeValidator.validateEdit(
            name: nameCtrl.text.trim(),
            email: emailCtrl.text.trim(),
            phone: phone,
            dob: formDob.value,
            groupId: selectedGroupId.value,
            genderId: selectedGenderId.value,
          )
        : EmployeeValidator.validateCreate(
            name: nameCtrl.text.trim(),
            email: emailCtrl.text.trim(),
            phone: phone,
            dob: formDob.value,
            groupId: selectedGroupId.value,
            genderId: selectedGenderId.value,
          );

    if (errors.isNotEmpty) {
      fieldErrors.assignAll(errors);
      return;
    }

    isSaving.value = true;
    try {
      if (isEditMode.value) {
        await _doUpdate();
      } else {
        await _doCreate();
      }
      Get.back();
    } catch (e) {
      _handleApiError(e, label: 'snack_label'.tr);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _doCreate() async {
    final phone = _toLocalDigits(phoneCtrl.text.trim());
    final emp = await _createEmployee(
      fullName: nameCtrl.text.trim(),
      email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
      phone: phone.isEmpty ? null : Validators.toE164(phone),
      placeOfBirth: placeCtrl.text.trim().isEmpty
          ? null
          : placeCtrl.text.trim(),
      dateOfBirth: formDob.value,
      genderId: selectedGenderId.value,
      groupIds: selectedGroupId.value != null ? [selectedGroupId.value!] : null,
      profileImagePath: profileImage.value?.path,
      role: selectedRole.value,
    );
    employees.insert(0, emp);
    allEmployees.insert(0, emp);
    AppSnackbar.success('snack_emp_added'.tr, 'snack_emp_added_msg'.tr);
  }

  Future<void> _doUpdate() async {
    final id = _editingId!;
    final phone = _toLocalDigits(phoneCtrl.text.trim());
    final emp = await _updateEmployee(
      id,
      fullName: nameCtrl.text.trim(),
      email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
      phone: phone.isEmpty ? null : Validators.toE164(phone),
      placeOfBirth: placeCtrl.text.trim().isEmpty
          ? null
          : placeCtrl.text.trim(),
      dateOfBirth: formDob.value,
      genderId: selectedGenderId.value,
      groupIds: selectedGroupId.value != null ? [selectedGroupId.value!] : null,
      profileImagePath: profileImage.value?.path,
      removeProfileImage: removeProfileImage.value,
      role: selectedRole.value,
    );
    final i = employees.indexWhere((e) => e.id == id);
    if (i != -1) employees[i] = emp;
    final j = allEmployees.indexWhere((e) => e.id == id);
    if (j != -1) allEmployees[j] = emp;
    AppSnackbar.update('snack_emp_updated'.tr, 'snack_emp_updated_msg'.tr);
  }

  // ── Image ─────────────────────────────────────────────────────
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) profileImage.value = picked;
  }

  /// Strips +855 / 855 / leading 0 so only local digits are stored.
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
    super.onClose();
  }
}
