import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:task_tracking_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:task_tracking_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_tracking_mobile/features/core/presentation/bindings/image_binding.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_employee_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_profile_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_task_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/bindings/manager_binding.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/splash_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/features/staff/presentation/controllers/task_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // ── Infrastructure ───────────────────────────────────────
    Get.put<AuthRepository>(
      AuthRepositoryImpl(AuthRemoteDatasource()),
      permanent: true,
    );

    // ── Core ─────────────────────────────────────────────────
    Get.put<NavigationController>(NavigationController(), permanent: true);
    Get.put<ThemeController>(ThemeController(), permanent: true);
    Get.put<TaskController>(TaskController(), permanent: true);

    // ── Auth ─────────────────────────────────────────────────
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<SplashController>(SplashController());

    // ── Feature bindings ─────────────────────────────────────
    ImageBinding().dependencies();
    ManagerBinding().dependencies();
    Get.put<AdminEmployeeController>(
      AdminEmployeeController(),
      permanent: true,
    );
    Get.put<AdminTaskController>(AdminTaskController(), permanent: true);
    Get.put<AdminProfileController>(AdminProfileController(), permanent: true);
  }
}
