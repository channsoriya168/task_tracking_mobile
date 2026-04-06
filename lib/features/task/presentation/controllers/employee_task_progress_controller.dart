import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_progress.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/create_task_progress_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/delete_task_progress_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/fetch_task_progresses_usecase.dart';
import 'package:task_tracking_mobile/features/task/domain/usecases/update_task_progress_usecase.dart';

class TaskProgressController extends GetxController {
  final FetchTaskProgressesUsecase _fetchTaskProgresses;
  final CreateTaskProgressUsecase _createTaskProgress;
  final UpdateTaskProgressUsecase _updateTaskProgress;
  final DeleteTaskProgressUsecase _deleteTaskProgress;

  TaskProgressController(
    this._fetchTaskProgresses,
    this._createTaskProgress,
    this._updateTaskProgress,
    this._deleteTaskProgress,
  );

  final RxList<TaskProgress> currentTaskProgresses = <TaskProgress>[].obs;
  final RxBool progressLoading = false.obs;
  final RxString progressError = ''.obs;

  Future<void> fetchTaskProgresses(String taskItemId) async {
    progressLoading.value = true;
    progressError.value = '';
    try {
      final result = await _fetchTaskProgresses(taskItemId);
      currentTaskProgresses.assignAll(result);
    } catch (e) {
      progressError.value = e.toString();
    } finally {
      progressLoading.value = false;
    }
  }

  Future<bool> createProgress(
    String taskItemId, {
    required int progressPercentage,
    required DateTime loggedAt,
    String? notes,
    double? hoursWorked,
  }) async {
    try {
      await _createTaskProgress(
        taskItemId,
        progressPercentage: progressPercentage,
        loggedAt: loggedAt,
        notes: notes,
        hoursWorked: hoursWorked,
      );
      await fetchTaskProgresses(taskItemId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateProgress(
    String taskItemId,
    String progressId, {
    required int progressPercentage,
    required DateTime loggedAt,
    required String notes,
    double? hoursWorked,
  }) async {
    try {
      await _updateTaskProgress(
        taskItemId,
        progressId,
        progressPercentage: progressPercentage,
        loggedAt: loggedAt,
        notes: notes,
        hoursWorked: hoursWorked,
      );
      await fetchTaskProgresses(taskItemId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteProgress(String taskItemId, String progressId) async {
    try {
      await _deleteTaskProgress(taskItemId, progressId);
      await fetchTaskProgresses(taskItemId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
