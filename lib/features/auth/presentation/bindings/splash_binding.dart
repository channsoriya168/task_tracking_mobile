import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/network/push_notification_service.dart';
import 'package:task_tracking_mobile/features/core/data/datasources/image_service.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/pick_and_compress_image_usecase.dart';
import 'package:task_tracking_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:task_tracking_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:task_tracking_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/generate_qr_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/qr_login_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/splash_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';
import 'package:task_tracking_mobile/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:task_tracking_mobile/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:task_tracking_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:task_tracking_mobile/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:task_tracking_mobile/features/profile/domain/usecases/fetch_profile_usecase.dart';
import 'package:task_tracking_mobile/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:task_tracking_mobile/features/profile/presentation/controllers/profile_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // ── Auth ──────────────────────────────────────────────────
    Get.put<AuthRepository>(
      AuthRepositoryImpl(AuthRemoteDatasource()),
      permanent: true,
    );
    Get.put(LogoutUsecase(Get.find()), permanent: true);
    Get.put(CheckAuthUsecase(Get.find()), permanent: true);
    Get.put(RefreshTokenUsecase(Get.find()), permanent: true);
    Get.put(QrLoginUsecase(Get.find()), permanent: true);
    Get.put(GenerateQrUsecase(Get.find()), permanent: true);

    // ── Profile ───────────────────────────────────────────────
    Get.put<ProfileRepository>(
      ProfileRepositoryImpl(ProfileRemoteDatasource()),
      permanent: true,
    );
    Get.put(FetchProfileUsecase(Get.find()), permanent: true);
    Get.put(ChangePasswordUsecase(Get.find()), permanent: true);
    Get.put(UpdateProfileUsecase(Get.find()), permanent: true);
    Get.put<ProfileController>(
      ProfileController(
        fetchProfileUsecase: Get.find(),
        changePasswordUsecase: Get.find(),
        updateProfileUsecase: Get.find(),
      ),
      permanent: true,
    );

    // ── Image ─────────────────────────────────────────────────
    Get.put(ImageService(), permanent: true);
    Get.put(PickAndCompressImageUseCase(Get.find()), permanent: true);

    // ── Core ──────────────────────────────────────────────────
    Get.put<AuthController>(
      AuthController(
        logoutUsecase: Get.find(),
        checkAuthUsecase: Get.find(),
        refreshTokenUsecase: Get.find(),
        qrLoginUsecase: Get.find(),
        generateQrUsecase: Get.find(),
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
