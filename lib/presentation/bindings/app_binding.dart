import 'package:get/get.dart';
import 'package:task_tracking_mobile/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/presentation/controllers/navigation_controller.dart';
import 'package:task_tracking_mobile/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/presentation/controllers/theme_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<NavigationController>(NavigationController(), permanent: true);
    Get.put<ThemeController>(ThemeController(), permanent: true);
    Get.put<TaskController>(TaskController(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
