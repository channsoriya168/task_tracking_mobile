import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/routes/app_routes.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';

class SplashController extends GetxController {
  final RxDouble progress = 0.0.obs;

  @override
  void onReady() {
    super.onReady();
    _run();
  }

  Future<void> _run() async {
    // Start progress bar animation after a short delay
    await Future.delayed(500.ms);
    progress.value = 1.0;

    // Wait for animation to finish then resolve session
    await Future.delayed(2900.ms);
    final hasSession = await Get.find<AuthController>().restoreSession();
    Get.offAllNamed(hasSession ? AppRoutes.mainPage : AppRoutes.login);
  }
}
