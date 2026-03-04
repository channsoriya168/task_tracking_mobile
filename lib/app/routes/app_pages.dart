import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/routes/app_routes.dart';
import 'package:task_tracking_mobile/presentation/bindings/app_binding.dart';
import 'package:task_tracking_mobile/presentation/pages/main_page.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.mainPage,
      page: () => const MainPage(),
      binding: AppBinding(),
    ),
  ];
}
