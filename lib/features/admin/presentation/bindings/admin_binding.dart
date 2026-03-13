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
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/update_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_task_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
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
    );
  }
}
