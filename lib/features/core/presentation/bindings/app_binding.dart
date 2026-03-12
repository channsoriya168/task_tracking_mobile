import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/admin/presentation/bindings/admin_binding.dart';
import 'package:task_tracking_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:task_tracking_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:task_tracking_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/splash_controller.dart';
import 'package:task_tracking_mobile/features/core/data/datasources/remote/employee_remote_datasource.dart';
import 'package:task_tracking_mobile/features/core/data/datasources/remote/task_group_remote_datasource.dart';
import 'package:task_tracking_mobile/features/core/data/repositories/employee_repository_impl.dart';
import 'package:task_tracking_mobile/features/core/data/repositories/task_group_repository_impl.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/employee_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_group_repository.dart';
import 'package:task_tracking_mobile/features/core/presentation/bindings/image_binding.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/bindings/employee_binding.dart';
import 'package:task_tracking_mobile/features/manager/presentation/bindings/manager_binding.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // ── Repositories (app-wide singletons) ───────────────────
    Get.put<AuthRepository>(
      AuthRepositoryImpl(AuthRemoteDatasource()),
      permanent: true,
    );
    Get.put<EmployeeRepository>(
      EmployeeRepositoryImpl(EmployeeRemoteDatasource()),
      permanent: true,
    );
    Get.put<TaskGroupRepository>(
      TaskGroupRepositoryImpl(TaskGroupRemoteDatasource()),
      permanent: true,
    );

    // ── Core controllers ──────────────────────────────────────
    Get.put<NavigationController>(NavigationController(), permanent: true);
    Get.put<ThemeController>(ThemeController(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<SplashController>(SplashController());

    // ── Feature bindings ──────────────────────────────────────
    ImageBinding().dependencies();
    AdminBinding().dependencies();
    ManagerBinding().dependencies();
    EmployeeBinding().dependencies();
  }
}