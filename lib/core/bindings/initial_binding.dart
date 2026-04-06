import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/theme_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ThemeController>(ThemeController(), permanent: true);
  }
}
