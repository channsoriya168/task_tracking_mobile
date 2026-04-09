import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/core/utils/validators.dart';
import 'package:task_tracking_mobile/features/profile/domain/entities/employee_profile.dart';
import 'package:task_tracking_mobile/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:task_tracking_mobile/features/profile/domain/usecases/fetch_profile_usecase.dart';
import 'package:task_tracking_mobile/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/pick_and_compress_image_usecase.dart';

class ProfileController extends GetxController {
  final FetchProfileUsecase fetchProfileUsecase;
  final ChangePasswordUsecase changePasswordUsecase;
  final UpdateProfileUsecase updateProfileUsecase;

  ProfileController({
    required this.fetchProfileUsecase,
    required this.changePasswordUsecase,
    required this.updateProfileUsecase,
  });

  final Rx<EmployeeProfile?> profile = Rx<EmployeeProfile?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUploadingImage = false.obs;
  final RxBool isChangingPassword = false.obs;
  final RxString changePasswordError = ''.obs;

  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void onInit() {
    super.onInit();
    currentPasswordController.addListener(_handlePasswordInputChange);
    newPasswordController.addListener(_handlePasswordInputChange);
    confirmPasswordController.addListener(_handlePasswordInputChange);

    ever(Get.find<NetworkController>().connectionStatus, (status) {
      if (status == ConnectionStatus.reconnected) fetchProfile();
    });
  }

  @override
  void onReady() {
    super.onReady();
    fetchProfile();
  }

  @override
  void onClose() {
    currentPasswordController.removeListener(_handlePasswordInputChange);
    newPasswordController.removeListener(_handlePasswordInputChange);
    confirmPasswordController.removeListener(_handlePasswordInputChange);
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void _handlePasswordInputChange() {
    final err = changePasswordError.value;
    if (err.isEmpty) return;

    final current = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (err.contains('required')) {
      if (current.isNotEmpty &&
          newPassword.isNotEmpty &&
          confirmPassword.isNotEmpty) {
        changePasswordError.value = '';
      }
      return;
    }

    if (err.contains('match')) {
      if (newPassword == confirmPassword) {
        changePasswordError.value = '';
      }
      return;
    }

    if (err.contains('Min 8')) {
      final passError = Validators.strongPassword(newPassword);
      if (passError == null) {
        changePasswordError.value = '';
      }
      return;
    }

    if (err.contains('incorrect')) {
      changePasswordError.value = '';
    }
  }

  // ── Fetch profile ─────────────────────────────────────────
  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final p = await fetchProfileUsecase();
      profile.value = p;
    } catch (e, st) {
      dev.log('fetchProfile error: $e', name: 'ProfileController', error: e, stackTrace: st);
    } finally {
      isLoading.value = false;
    }
  }

  void clearProfile() {
    profile.value = null;
  }

  // ── Change password ───────────────────────────────────────
  Future<void> changePassword() async {
    if (currentPasswordController.text.trim().isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      changePasswordError.value = 'All fields are required.';
      return;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      changePasswordError.value = 'New passwords do not match.';
      return;
    }
    final passError = Validators.strongPassword(newPasswordController.text);
    if (passError != null) {
      changePasswordError.value = passError;
      return;
    }

    isChangingPassword.value = true;
    changePasswordError.value = '';
    try {
      await changePasswordUsecase(
        currentPassword: currentPasswordController.text.trim(),
        newPassword: newPasswordController.text,
        confirmNewPassword: confirmPasswordController.text,
      );
      Get.back();
      AppSnackbar.success('snack_success'.tr, 'snack_pwd_changed'.tr);
    } catch (e) {
      changePasswordError.value = e.toString();
    } finally {
      isChangingPassword.value = false;
    }
  }

  // ── Profile image ─────────────────────────────────────────
  Future<void> pickAndUploadProfileImage(ImageSource source) async {
    final pickImage = Get.find<PickAndCompressImageUseCase>();
    final File? file = await pickImage(source);
    if (file == null) return;
    isUploadingImage.value = true;
    try {
      await updateProfileUsecase(image: file);
      await fetchProfile();
      AppSnackbar.success('snack_success'.tr, 'snack_photo_updated'.tr);
    } catch (e) {
      AppSnackbar.error('snack_error'.tr, e.toString());
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> removeProfileImage() async {
    isUploadingImage.value = true;
    try {
      await updateProfileUsecase(removeImage: true);
      await fetchProfile();
      AppSnackbar.success('snack_success'.tr, 'snack_photo_removed'.tr);
    } catch (e) {
      AppSnackbar.error('snack_error'.tr, e.toString());
    } finally {
      isUploadingImage.value = false;
    }
  }
}
