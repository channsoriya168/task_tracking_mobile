import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/routes/app_routes.dart';
import 'package:task_tracking_mobile/data/models/user_model.dart';
import 'package:task_tracking_mobile/presentation/controllers/navigation_controller.dart';

class AuthController extends GetxController {
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  UserRole? get role => currentUser.value?.role;

  void login(UserModel user) {
    currentUser.value = user;
    Get.find<NavigationController>().changePage(0);
    Get.offAllNamed(AppRoutes.mainPage);
  }

  void logout() {
    currentUser.value = null;
    Get.find<NavigationController>().changePage(0);
    Get.offAllNamed(AppRoutes.login);
  }
}
