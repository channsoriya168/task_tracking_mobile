import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/label.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/create_label_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/delete_label_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/get_all_labels_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/update_label_usecase.dart';

class AdminLabelController extends GetxController {
  final GetAllLabelsUseCase _getAll;
  final CreateLabelUseCase _create;
  final UpdateLabelUseCase _update;
  final DeleteLabelUseCase _delete;

  AdminLabelController(this._getAll, this._create, this._update, this._delete);

  final RxList<Label> labels = <Label>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  final nameCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final RxString nameError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLabels();
  }

  Future<void> fetchLabels() async {
    isLoading.value = true;
    try {
      labels.assignAll(await _getAll());
    } catch (_) {
      AppSnackbar.error('Labels', 'Failed to load labels.');
    } finally {
      isLoading.value = false;
    }
  }

  void initForm([Label? existing]) {
    nameCtrl.text = existing?.name ?? '';
    descriptionCtrl.text = existing?.description ?? '';
    nameError.value = '';
  }

  Future<bool> createLabel() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      nameError.value = 'Label name is required';
      return false;
    }
    nameError.value = '';
    isSaving.value = true;
    try {
      final created = await _create(
        name: name,
        description: descriptionCtrl.text.trim().isEmpty
            ? null
            : descriptionCtrl.text.trim(),
      );
      labels.add(created);
      AppSnackbar.success('Label Added', '"${created.name}" has been created.');
      return true;
    } catch (_) {
      AppSnackbar.error('Labels', 'Failed to create label.');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateLabel(String id) async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      nameError.value = 'Label name is required';
      return false;
    }
    nameError.value = '';
    isSaving.value = true;
    try {
      final updated = await _update(
        id,
        name: name,
        description: descriptionCtrl.text.trim().isEmpty
            ? null
            : descriptionCtrl.text.trim(),
      );
      final i = labels.indexWhere((l) => l.id == id);
      if (i != -1) labels[i] = updated;
      AppSnackbar.update('Label Updated', '"${updated.name}" has been updated.');
      return true;
    } catch (_) {
      AppSnackbar.error('Labels', 'Failed to update label.');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteLabel(String id) async {
    final label = labels.firstWhereOrNull((l) => l.id == id);
    if (label == null) return;
    try {
      await _delete(id);
      labels.removeWhere((l) => l.id == id);
      AppSnackbar.delete('Label Deleted', '"${label.name}" has been removed.');
    } catch (_) {
      AppSnackbar.error('Labels', 'Failed to delete label.');
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descriptionCtrl.dispose();
    super.onClose();
  }
}
