import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';

class PositionController extends GetxController {
  final RxList<Position> positions = <Position>[].obs;

  @override
  void onInit() {
    super.onInit();
    positions.addAll(kMockPositions);
  }

  Position? findPosition(String id) {
    try {
      return positions.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void addPosition(Position position) {
    positions.add(position);
    AppSnackbar.success(
      'Position Added',
      '"${position.name}" has been created.',
    );
  }

  void updatePosition(Position updated) {
    final i = positions.indexWhere((p) => p.id == updated.id);
    if (i == -1) return;
    positions[i] = updated;
    AppSnackbar.update(
      'Position Updated',
      '"${updated.name}" has been updated.',
    );
  }

  void deletePosition(String id) {
    final pos = findPosition(id);
    if (pos == null) return;
    positions.removeWhere((p) => p.id == id);
    Get.find<EmployeeController>().employees.removeWhere(
      (e) => e.positionId == id,
    );
    AppSnackbar.delete('Position Deleted', '"${pos.name}" has been removed.');
  }

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}
