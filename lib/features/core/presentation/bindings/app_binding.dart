import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/employee/domain/usecases/create_employee_usecase.dart';
import 'package:task_tracking_mobile/features/group/domain/usecases/create_group_usecase.dart';
import 'package:task_tracking_mobile/features/group/domain/usecases/delete_group_usecase.dart';
import 'package:task_tracking_mobile/features/group/domain/usecases/update_group_usecase.dart';
import 'package:task_tracking_mobile/features/group/domain/usecases/get_all_groups_usecase.dart';
import 'package:task_tracking_mobile/features/group/data/datasources/group_remote_datasource.dart';
import 'package:task_tracking_mobile/features/lookup/data/datasources/lookup_remote_datasource.dart';
import 'package:task_tracking_mobile/features/task/data/datasources/task_item_remote_datasource.dart';
import 'package:task_tracking_mobile/features/employee/data/repositories/employee_repository_impl.dart';
import 'package:task_tracking_mobile/features/lookup/data/repositories/lookup_repository_impl.dart';
import 'package:task_tracking_mobile/features/group/data/repositories/group_repository_impl.dart';
import 'package:task_tracking_mobile/features/task/data/repositories/task_item_repository_impl.dart';
import 'package:task_tracking_mobile/features/employee/domain/repositories/employee_repository.dart';
import 'package:task_tracking_mobile/features/lookup/domain/repositories/lookup_repository.dart';
import 'package:task_tracking_mobile/features/group/domain/repositories/group_repository.dart';
import 'package:task_tracking_mobile/features/task/domain/repositories/task_item_repository.dart';
import 'package:task_tracking_mobile/features/employee/data/datasources/employee_remote_datasource.dart';
import 'package:task_tracking_mobile/features/label/data/label_remote_datasource.dart';
import 'package:task_tracking_mobile/features/label/data/label_repository_impl.dart';
import 'package:task_tracking_mobile/features/label/domain/repositories/label_repository.dart';
import 'package:task_tracking_mobile/features/label/domain/usecases/get_all_labels_usecase.dart';
import 'package:task_tracking_mobile/features/label/domain/usecases/create_label_usecase.dart';
import 'package:task_tracking_mobile/features/employee/domain/usecases/reset_employee_password_usecase.dart';
import 'package:task_tracking_mobile/features/employee/domain/usecases/update_employee_usecase.dart';
import 'package:task_tracking_mobile/features/label/domain/usecases/update_label_usecase.dart';
import 'package:task_tracking_mobile/features/label/domain/usecases/delete_label_usecase.dart';
import 'package:task_tracking_mobile/features/label/presentation/controllers/label_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/bindings/task_binding.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';
import 'package:task_tracking_mobile/features/dashboard/bindings/employee_binding.dart';
import 'package:task_tracking_mobile/features/group/presentation/controllers/group_controller.dart';
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
    Get.put<GroupRepository>(
      GroupRepositoryImpl(GroupRemoteDatasource()),
      permanent: true,
    );
    Get.put<TaskItemRepository>(
      TaskItemRepositoryImpl(TaskItemRemoteDatasource()),
      permanent: true,
    );
    Get.put<LookupRepository>(
      LookupRepositoryImpl(LookupRemoteDatasource()),
      permanent: true,
    );
    Get.put<LabelRepository>(
      LabelRepositoryImpl(LabelRemoteDatasource()),
      permanent: true,
    );
    Get.put<NotificationRepository>(
      NotificationRepositoryImpl(NotificationRemoteDatasource()),
      permanent: true,
    );
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
    Get.lazyPut<GroupController>(
      () => GroupController(
        GetAllGroupsUseCase(Get.find<GroupRepository>()),
        CreateGroupUseCase(Get.find<GroupRepository>()),
        UpdateGroupUseCase(Get.find<GroupRepository>()),
        DeleteGroupUseCase(Get.find<GroupRepository>()),
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
        Get.find<LookupRepository>(),
      ),
      fenix: true,
    );
    EmployeeBinding().dependencies();
    Get.lazyPut<LabelController>(
      () => LabelController(
        GetAllLabelsUseCase(Get.find<LabelRepository>()),
        CreateLabelUseCase(Get.find<LabelRepository>()),
        UpdateLabelUseCase(Get.find<LabelRepository>()),
        DeleteLabelUseCase(Get.find<LabelRepository>()),
      ),
      fenix: true,
    );
  }
}
