import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/services/shorebird_service.dart';
import 'package:task_tracking_mobile/routes/app_routes.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';

class SplashController extends GetxController {
  final RxDouble progress = 0.0.obs;

  @override
  void onReady() {
    super.onReady();
    _run();
  }

  Future<void> _run() async {
    // Check for patch in parallel with the splash animation
    final updateFuture = Get.find<ShorebirdService>().checkAndUpdate();

    await Future.delayed(500.ms);
    progress.value = 1.0;
    await Future.delayed(2900.ms);

    await updateFuture;

    final isValid = await Get.find<AuthController>().checkAuth();
    if (isValid) {
      Get.offAllNamed(AppRoutes.mainPage);
    } else if (Get.currentRoute != AppRoutes.login) {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
