import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/middleware/auth_middleware.dart';
import 'package:task_tracking_mobile/features/attendence/presentation/pages/attendance_page.dart';
import 'package:task_tracking_mobile/routes/app_routes.dart';
import 'package:task_tracking_mobile/features/auth/presentation/bindings/splash_binding.dart';
import 'package:task_tracking_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:task_tracking_mobile/features/auth/presentation/pages/splash_page.dart';
import 'package:task_tracking_mobile/features/core/presentation/bindings/app_binding.dart';
import 'package:task_tracking_mobile/features/core/presentation/pages/main_page.dart';
import 'package:task_tracking_mobile/features/notification/presentation/pages/notification_page.dart';
import 'package:task_tracking_mobile/features/task/presentation/pages/employee_task_detail.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(
      name: AppRoutes.mainPage,
      page: () => const MainPage(),
      binding: AppBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationPage(),
    ),
    GetPage(
      name: AppRoutes.taskDetail,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return EmployeeTaskDetailPage(
          task: args['task'] as TaskItem,
          isDark: args['isDark'] as bool,
          readOnly: (args['readOnly'] as bool?) ?? false,
        );
      },
    ),
    GetPage(name: AppRoutes.attendance, page: () => AttendancePage()),
  ];
}
