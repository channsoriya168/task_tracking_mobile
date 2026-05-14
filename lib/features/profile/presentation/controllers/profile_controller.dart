import 'dart:developer' as dev;
import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/features/profile/domain/entities/employee_profile.dart';
import 'package:task_tracking_mobile/features/profile/domain/usecases/fetch_profile_usecase.dart';
import 'package:task_tracking_mobile/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/pick_and_compress_image_usecase.dart';

class ProfileController extends GetxController {
  final FetchProfileUsecase fetchProfileUsecase;
  final UpdateProfileUsecase updateProfileUsecase;

  ProfileController({
    required this.fetchProfileUsecase,
    required this.updateProfileUsecase,
  });

  final Rx<EmployeeProfile?> profile = Rx<EmployeeProfile?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUploadingImage = false.obs;

  @override
  void onInit() {
    super.onInit();

    ever(Get.find<NetworkController>().connectionStatus, (status) {
      if (status == ConnectionStatus.reconnected) fetchProfile();
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // ── Fetch profile ─────────────────────────────────────────
  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final p = await fetchProfileUsecase();
      profile.value = p;
    } catch (e, st) {
      dev.log(
        'fetchProfile error: $e',
        name: 'ProfileController',
        error: e,
        stackTrace: st,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearProfile() {
    profile.value = null;
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
