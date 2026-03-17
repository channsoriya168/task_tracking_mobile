import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/label_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/lookup_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_item_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_task_priorities_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_task_statuses_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/get_all_labels_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/create_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/delete_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/fetch_task_item.usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/fetch_task_item_by_id_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/update_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/manager_dashboard_controller.dart';

class ManagerTaskBinding extends Bindings {
  @override
  void dependencies() {
    // ── Dashboard: own fetch/filter state, no CRUD ────────────
    Get.lazyPut<ManagerDashboardController>(
      () => ManagerDashboardController(
        FetchTaskItemsUsecase(Get.find<TaskItemRepository>()),
        FetchTaskItemByIdUsecase(Get.find<TaskItemRepository>()),
        FetchTaskStatusesUsecase(Get.find<LookupRepository>()),
      ),
      fenix: true,
    );

    // ── Task page: full CRUD + filter state ───────────────────
    Get.lazyPut<TaskController>(
      () => TaskController(
        FetchTaskItemsUsecase(Get.find<TaskItemRepository>()),
        FetchTaskItemByIdUsecase(Get.find<TaskItemRepository>()),
        CreateTaskItemUsecase(Get.find<TaskItemRepository>()),
        UpdateTaskItemUsecase(Get.find<TaskItemRepository>()),
        DeleteTaskItemUsecase(Get.find<TaskItemRepository>()),
        FetchTaskPrioritiesUsecase(Get.find<LookupRepository>()),
        FetchTaskStatusesUsecase(Get.find<LookupRepository>()),
        GetAllLabelsUseCase(Get.find<LabelRepository>()),
      ),
      fenix: true,
    );
  }
}
