import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/employee_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<EmployeeController>(EmployeeController(), permanent: true);
  }
}