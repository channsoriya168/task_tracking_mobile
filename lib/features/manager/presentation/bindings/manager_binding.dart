import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/manager_task_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/position_controller.dart';

class ManagerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PositionController>(PositionController(), permanent: true);
    Get.lazyPut<EmployeeController>(() => EmployeeController());
    Get.lazyPut<ManagerTaskController>(() => ManagerTaskController());
  }
}
