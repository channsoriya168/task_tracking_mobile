import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/services/push_notification_service.dart';
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
    Get.put<AuthController>(
      AuthController(
        loginUsecase: Get.find(),
        logoutUsecase: Get.find(),
        fetchProfileUsecase: Get.find(),
        checkAuthUsecase: Get.find(),
        refreshTokenUsecase: Get.find(),
        changePasswordUsecase: Get.find(),
        updateProfileUsecase: Get.find(),
      ),
      permanent: true,
    );
    Get.put<NavigationController>(NavigationController(), permanent: true);

    // Initialize push notification service.
    // Note: onBackgroundMessage is intentionally omitted — FCM notification
    // payloads are displayed automatically by the OS without a background
    // handler. A handler is only needed for custom data-only message
    // processing, which this app does not use. Registering one spawns a
    // second Flutter engine that crashes on 16 KB-page-size emulators.
    Get.putAsync<PushNotificationService>(
      () => PushNotificationService().init(),
      permanent: true,
    );

    Get.lazyPut(() => SplashController());
  }
}
