import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/pick_and_compress_image_usecase.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/image_picker_bottom_sheet.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/position_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_dialog.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/position_dialog.dart';

class EmployeeController extends GetxController {
  final RxList<Employee> employees = <Employee>[].obs;
  final RxString searchQuery = ''.obs;
  final PickAndCompressImageUseCase pickImage = Get.find();

  // Track the employee being edited
  Employee? existing;

  RxList<Position> get positions => Get.find<PositionController>().positions;

  @override
  void onInit() {
    super.onInit();
    employees.addAll(kMockEmployees);
  }

  Future<void> pickFromGallery() async {
    final result = await pickImage(ImageSource.gallery);

    if (result != null) {
      formImagePath.value = result.path;
    }
  }

  Future<void> pickFromCamera() async {
    final result = await pickImage(ImageSource.camera);

    if (result != null) {
      formImagePath.value = result.path;
    }
  }

  void showImagePickerOptions([bool isDark = false]) {
    ImagePickerBottomSheet.show(
      isDark: isDark,
      onCameraTap: pickFromCamera,
      onGalleryTap: pickFromGallery,
    );
  }

  Future<void> onOpenPositionDialog(BuildContext context) async {
    final posCtrl = Get.find<PositionController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final before = posCtrl.positions.map((p) => p.id).toSet();

    await showPositionDialog(context, posCtrl, isDark);

    final added = posCtrl.positions
        .where((p) => !before.contains(p.id))
        .toList();
    if (added.isNotEmpty) formPositionId.value = added.first.id;
  }

  List<Employee> get filteredEmployees {
    if (searchQuery.value.isEmpty) return employees.toList();
    final q = searchQuery.value.toLowerCase();
    return employees.where((e) {
      return e.name.toLowerCase().contains(q) ||
          e.email.toLowerCase().contains(q);
    }).toList();
  }

  List<Employee> employeesByPosition(String positionId) {
    return filteredEmployees.where((e) => e.positionId == positionId).toList();
  }

  Position? findPosition(String id) {
    try {
      return positions.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  int employeeCountByPosition(String positionId) =>
      employees.where((e) => e.positionId == positionId).length;

  // ── Dialog form state ──────────────────────────────────────────
  final Rx<String?> formImagePath = Rx(null);
  final RxString formPositionId = ''.obs;
  final Rx<DateTime?> formDob = Rx(null);

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final placeCtrl = TextEditingController();

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    placeCtrl.dispose();
    super.onClose();
  }

  void initDialogForm(Employee? existing, String? preselectedPositionId) {
    this.existing = existing;
    formImagePath.value = existing?.imagePath;
    formPositionId.value =
        existing?.positionId ??
        preselectedPositionId ??
        positions.firstOrNull?.id ??
        '';
    formDob.value = existing?.dateOfBirth;
    nameCtrl.text = existing?.name ?? '';
    emailCtrl.text = existing?.email ?? '';
    phoneCtrl.text = existing?.phone ?? '';
    placeCtrl.text = existing?.placeOfBirth ?? '';
  }

  void showDialog(
    bool isDark, [
    Employee? existing,
    String? preselectedPositionId,
  ]) {
    initDialogForm(existing, preselectedPositionId);
    Get.bottomSheet(
      EmployeeDialogSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void saveEmployee() {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final phone = phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim();
    final placeOfBirth = placeCtrl.text.trim().isEmpty
        ? null
        : placeCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || formPositionId.value.isEmpty) return;

    if (existing == null) {
      addEmployee(
        Employee(
          id: generateId(),
          name: name,
          email: email,
          positionId: formPositionId.value,
          imagePath: formImagePath.value,
          dateOfBirth: formDob.value,
          placeOfBirth: placeOfBirth,
          phone: phone,
        ),
      );
    } else {
      updateEmployee(
        existing!.copyWith(
          name: name,
          email: email,
          positionId: formPositionId.value,
          imagePath: formImagePath.value,
          dateOfBirth: formDob.value,
          placeOfBirth: placeOfBirth,
          phone: phone,
        ),
      );
    }
    Get.back();
  }

  void addEmployee(Employee employee) => employees.add(employee);

  void updateEmployee(Employee updated) {
    final i = employees.indexWhere((e) => e.id == updated.id);
    if (i != -1) employees[i] = updated;
  }

  void deleteEmployee(String id) => employees.removeWhere((e) => e.id == id);

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}
