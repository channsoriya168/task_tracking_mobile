import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/features/label/domain/entities/label.dart';
import 'package:task_tracking_mobile/features/label/domain/usecases/create_label_usecase.dart';
import 'package:task_tracking_mobile/features/label/domain/usecases/delete_label_usecase.dart';
import 'package:task_tracking_mobile/features/label/domain/usecases/get_all_labels_usecase.dart';
import 'package:task_tracking_mobile/features/label/domain/usecases/update_label_usecase.dart';

class LabelController extends GetxController {
  final GetAllLabelsUseCase _getAll;
  final CreateLabelUseCase _create;
  final UpdateLabelUseCase _update;
  final DeleteLabelUseCase _delete;

  LabelController(this._getAll, this._create, this._update, this._delete);

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
      nameError.value = 'label_name_required'.tr;
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
      AppSnackbar.success(
        'snack_label_added'.tr,
        'snack_label_added_msg'.trParams({'name': created.name}),
      );
      return true;
    } catch (_) {
      AppSnackbar.error('snack_label'.tr, 'snack_label_create_fail'.tr);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateLabel(String id) async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      nameError.value = 'label_name_required'.tr;
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
      AppSnackbar.update(
        'snack_label_updated'.tr,
        'snack_label_updated_msg'.trParams({'name': updated.name}),
      );
      return true;
    } catch (_) {
      AppSnackbar.error('snack_label'.tr, 'snack_label_update_fail'.tr);
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
      AppSnackbar.delete(
        'snack_label_deleted'.tr,
        'snack_label_deleted_msg'.trParams({'name': label.name}),
      );
    } catch (_) {
      AppSnackbar.error('snack_label'.tr, 'snack_label_delete_fail'.tr);
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descriptionCtrl.dispose();
    super.onClose();
  }
}
