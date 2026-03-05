import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';

class ManagerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<EmployeeController>(EmployeeController(), permanent: true);
  }
}
