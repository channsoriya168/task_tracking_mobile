import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/routes/app_routes.dart';
import 'package:task_tracking_mobile/presentation/bindings/app_binding.dart';
import 'package:task_tracking_mobile/presentation/pages/home_page.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: AppBinding(),
    ),
  ];
}