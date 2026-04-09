import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/label/domain/repositories/label_repository.dart';
import 'package:task_tracking_mobile/features/lookup/domain/repositories/lookup_repository.dart';
import 'package:task_tracking_mobile/features/task/domain/repositories/task_item_repository.dart';
import 'package:task_tracking_mobile/features/lookup/domain/usecases/fetch_task_priorities_usecase.dart';
import 'package:task_tracking_mobile/features/lookup/domain/usecases/fetch_task_statuses_usecase.dart';
import 'package:task_tracking_mobile/features/label/domain/usecases/get_all_labels_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/create_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/delete_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/fetch_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/fetch_task_item_by_id_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/update_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/task_controller.dart';

class ManagerTaskBinding extends Bindings {
  @override
  void dependencies() {
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
