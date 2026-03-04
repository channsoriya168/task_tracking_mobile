import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/routes/app_routes.dart';
import 'package:task_tracking_mobile/presentation/bindings/app_binding.dart';
import 'package:task_tracking_mobile/presentation/pages/auth/login_page.dart';
import 'package:task_tracking_mobile/presentation/pages/main_page.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AppBinding(), // ensures all controllers exist from the start
    ),
    GetPage(
      name: AppRoutes.mainPage,
      page: () => const MainPage(),
    ),
  ];
}
