import 'package:get/get.dart';
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
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_employees_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/create_employee_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/update_employee_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/delete_employee_usecase.dart';
import 'package:task_tracking_mobile/features/core/data/datasources/remote/label_remote_datasource.dart';
import 'package:task_tracking_mobile/features/core/data/repositories/label_repository_impl.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/label_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/get_all_labels_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/create_label_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/update_label_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/delete_label_usecase.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_employee_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_employee_form_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_label_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_task_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_task_group_controller.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_task_priorities_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_task_statuses_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/create_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/delete_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/fetch_task_item.usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/update_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/create_task_group_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/delete_task_group_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/get_all_task_groups_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/update_task_group_usecase.dart';
import 'package:task_tracking_mobile/features/manager/presentation/bindings/manager_task_binding.dart';
import 'package:task_tracking_mobile/features/manager/presentation/bindings/manager_employee_binding.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/bindings/employee_binding.dart';

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

    // ── Core controllers ──────────────────────────────────────
    if (!Get.isRegistered<NavigationController>()) {
      Get.put<NavigationController>(NavigationController(), permanent: true);
    }

    // ── Feature bindings ──────────────────────────────────────
    ManagerTaskBinding().dependencies();
    ManagerEmployeeBinding().dependencies();
    EmployeeBinding().dependencies();

    // ── Admin controllers ─────────────────────────────────────
    Get.lazyPut<AdminEmployeeController>(
      () => AdminEmployeeController(
        FetchEmployeesUsecase(Get.find<EmployeeRepository>()),
        DeleteEmployeeUsecase(Get.find<EmployeeRepository>()),
      ),
      fenix: true,
    );
    Get.lazyPut<AdminEmployeeFormController>(
      () => AdminEmployeeFormController(
        CreateEmployeeUsecase(Get.find<EmployeeRepository>()),
        UpdateEmployeeUsecase(Get.find<EmployeeRepository>()),
      ),
      fenix: true,
    );
    Get.lazyPut<AdminTaskController>(
      () => AdminTaskController(
        FetchTaskItemsUsecase(Get.find<TaskItemRepository>()),
        CreateTaskItemUsecase(Get.find<TaskItemRepository>()),
        UpdateTaskItemUsecase(Get.find<TaskItemRepository>()),
        DeleteTaskItemUsecase(Get.find<TaskItemRepository>()),
        FetchTaskPrioritiesUsecase(Get.find<LookupRepository>()),
        FetchTaskStatusesUsecase(Get.find<LookupRepository>()),
        GetAllLabelsUseCase(Get.find<LabelRepository>()),
      ),
      fenix: true,
    );
    Get.lazyPut<AdminTaskGroupController>(
      () => AdminTaskGroupController(
        GetAllTaskGroupsUseCase(Get.find<TaskGroupRepository>()),
        CreateTaskGroupUseCase(Get.find<TaskGroupRepository>()),
        UpdateTaskGroupUseCase(Get.find<TaskGroupRepository>()),
        DeleteTaskGroupUseCase(Get.find<TaskGroupRepository>()),
      ),
      fenix: true,
    );
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