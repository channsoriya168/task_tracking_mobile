import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_group_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/get_all_task_groups_usecase.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/manager_task_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/task_group_controller.dart';

class ManagerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TaskGroupController>(
      TaskGroupController(
        GetAllTaskGroupsUseCase(Get.find<TaskGroupRepository>()),
      ),
      permanent: true,
    );
    Get.lazyPut<EmployeeController>(() => EmployeeController());
    Get.lazyPut<ManagerTaskController>(() => ManagerTaskController());
  }
}
