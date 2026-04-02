import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/core/data/datasources/image_service.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/create_employee_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/create_task_group_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/get_all_task_groups_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/pick_and_compress_image_usecase.dart';
import 'package:task_tracking_mobile/features/core/data/datasources/remote/task_group_remote_datasource.dart';
import 'package:task_tracking_mobile/features/core/data/datasources/remote/lookup_remote_datasource.dart';
import 'package:task_tracking_mobile/features/core/data/datasources/remote/task_item_remote_datasource.dart';
import 'package:task_tracking_mobile/features/core/data/repositories/employee_repository_impl.dart';
import 'package:task_tracking_mobile/features/core/data/repositories/lookup_repository_impl.dart';
import 'package:task_tracking_mobile/features/core/data/repositories/task_group_repository_impl.dart';
import 'package:task_tracking_mobile/features/core/data/repositories/task_item_repository_impl.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/employee_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/lookup_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_group_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_item_repository.dart';
import 'package:task_tracking_mobile/features/core/data/datasources/remote/employee_remote_datasource.dart';
import 'package:task_tracking_mobile/features/core/data/datasources/remote/label_remote_datasource.dart';
import 'package:task_tracking_mobile/features/core/data/repositories/label_repository_impl.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/label_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/get_all_labels_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/create_label_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/reset_employee_password_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/update_employee_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/update_label_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/delete_label_usecase.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_label_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/bindings/task_binding.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/bindings/employee_binding.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/task_group_controller.dart';
import 'package:task_tracking_mobile/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:task_tracking_mobile/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:task_tracking_mobile/features/notification/domain/repositories/notification_repository.dart';
import 'package:task_tracking_mobile/features/notification/presentation/controllers/notification_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // ── Repositories ──────────────────────────────────────────
    Get.put<EmployeeRepository>(
      EmployeeRepositoryImpl(EmployeeRemoteDatasource()),
      permanent: true,
    );
    Get.put<TaskGroupRepository>(
      TaskGroupRepositoryImpl(TaskGroupRemoteDatasource()),
      permanent: true,
    );
    Get.put<TaskItemRepository>(
      TaskItemRepositoryImpl(TaskItemRemoteDatasource()),
      permanent: true,
    );
    Get.put<LookupRepository>(LookupRepositoryImpl(LookupRemoteDatasource()));
    Get.put<LabelRepository>(
      LabelRepositoryImpl(LabelRemoteDatasource()),
      permanent: true,
    );
    Get.put<NotificationRepository>(
      NotificationRepositoryImpl(NotificationRemoteDatasource()),
      permanent: true,
    );

    // ── Image ─────────────────────────────────────────────────
    Get.lazyPut(() => ImageService(), fenix: true);
    Get.lazyPut(() => PickAndCompressImageUseCase(Get.find()), fenix: true);

    // ── Core controllers ──────────────────────────────────────
    if (!Get.isRegistered<NavigationController>()) {
      Get.put<NavigationController>(NavigationController(), permanent: true);
    }

    // ── Notification controller ───────────────────────────────
    Get.put<NotificationController>(
      NotificationController(Get.find<NotificationRepository>()),
      permanent: true,
    );

    // ── Feature bindings ──────────────────────────────────────
    ManagerTaskBinding().dependencies();
    Get.lazyPut<TaskGroupController>(
      () => TaskGroupController(
        GetAllTaskGroupsUseCase(Get.find<TaskGroupRepository>()),
        CreateTaskGroupUseCase(Get.find<TaskGroupRepository>()),
      ),
      fenix: true,
    );
    Get.lazyPut<EmployeeRepository>(
      () => EmployeeRepositoryImpl(EmployeeRemoteDatasource()),
      fenix: true,
    );
    Get.lazyPut<EmployeeController>(
      () => EmployeeController(
        Get.find<EmployeeRepository>(),
        CreateEmployeeUsecase(Get.find<EmployeeRepository>()),
        UpdateEmployeeUsecase(Get.find<EmployeeRepository>()),
        ResetEmployeePasswordUsecase(Get.find<EmployeeRepository>()),
      ),
      fenix: true,
    );
    EmployeeBinding().dependencies();
    Get.lazyPut<AdminLabelController>(
      () => AdminLabelController(
        GetAllLabelsUseCase(Get.find<LabelRepository>()),
        CreateLabelUseCase(Get.find<LabelRepository>()),
        UpdateLabelUseCase(Get.find<LabelRepository>()),
        DeleteLabelUseCase(Get.find<LabelRepository>()),
      ),
      fenix: true,
    );
  }
}
