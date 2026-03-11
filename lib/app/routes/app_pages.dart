import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/middleware/auth_middleware.dart';
import 'package:task_tracking_mobile/app/routes/app_routes.dart';
import 'package:task_tracking_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:task_tracking_mobile/features/auth/presentation/pages/splash_page.dart';
import 'package:task_tracking_mobile/features/core/presentation/bindings/app_binding.dart';
import 'package:task_tracking_mobile/features/core/presentation/pages/main_page.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: AppBinding(), // register all controllers at app start
    ),
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(
      name: AppRoutes.mainPage,
      page: () => const MainPage(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
