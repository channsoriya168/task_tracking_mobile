import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/admin/presentation/bindings/admin_binding.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/features/staff/presentation/controllers/task_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<NavigationController>(NavigationController(), permanent: true);
    Get.put<ThemeController>(ThemeController(), permanent: true);
    Get.put<TaskController>(TaskController(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
    AdminBinding().dependencies();
  }
}
