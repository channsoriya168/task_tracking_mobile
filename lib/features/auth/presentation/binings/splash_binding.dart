import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:task_tracking_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:task_tracking_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/splash_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthRepository>(
      AuthRepositoryImpl(AuthRemoteDatasource()),
      permanent: true,
    );
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<NavigationController>(NavigationController(), permanent: true);
    Get.lazyPut(() => SplashController());
  }
}
