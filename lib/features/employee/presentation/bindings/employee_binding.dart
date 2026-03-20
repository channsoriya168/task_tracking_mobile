import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/employee_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/lookup_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_item_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_employees_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_task_statuses_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/add_task_member_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/assign_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/create_task_progress_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/delete_task_progress_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/update_task_progress_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/fetch_task_item.usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/fetch_task_members_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/fetch_task_progresses_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/remove_task_member_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/update_task_item_status_usecase.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_task_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/home_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/task_comment_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/task_member_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/task_progress_controller.dart';

class EmployeeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeTaskController>(
      () => EmployeeTaskController(
        FetchTaskItemsUsecase(Get.find<TaskItemRepository>()),
        FetchTaskStatusesUsecase(Get.find<LookupRepository>()),
        UpdateTaskItemStatusUsecase(Get.find<TaskItemRepository>()),
      ),
      fenix: true,
    );

    Get.lazyPut<TaskMemberController>(
      () => TaskMemberController(
        FetchTaskMembersUsecase(Get.find<TaskItemRepository>()),
        AddTaskMemberUsecase(Get.find<TaskItemRepository>()),
        RemoveTaskMemberUsecase(Get.find<TaskItemRepository>()),
        FetchEmployeesUsecase(Get.find<EmployeeRepository>()),
      ),
      fenix: true,
    );

    Get.lazyPut<TaskCommentController>(() => TaskCommentController(), fenix: true);

    Get.lazyPut<HomeController>(
      () => HomeController(
        FetchTaskItemsUsecase(Get.find<TaskItemRepository>()),
        FetchTaskStatusesUsecase(Get.find<LookupRepository>()),
        AssignTaskItemUsecase(Get.find<TaskItemRepository>()),
        UpdateTaskItemStatusUsecase(Get.find<TaskItemRepository>()),
      ),
      fenix: true,
    );

    Get.lazyPut<TaskProgressController>(
      () => TaskProgressController(
        FetchTaskProgressesUsecase(Get.find<TaskItemRepository>()),
        CreateTaskProgressUsecase(Get.find<TaskItemRepository>()),
        UpdateTaskProgressUsecase(Get.find<TaskItemRepository>()),
        DeleteTaskProgressUsecase(Get.find<TaskItemRepository>()),
      ),
      fenix: true,
    );
  }
}