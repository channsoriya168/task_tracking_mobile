import 'package:task_tracking_mobile/features/core/domain/repositories/task_item_repository.dart';

class UpdateTaskProgressUsecase {
  final TaskItemRepository _repo;
  const UpdateTaskProgressUsecase(this._repo);

  Future<void> call(
    String taskItemId,
    String progressId, {
    required int progressPercentage,
    required DateTime loggedAt,
    required String notes,
    double? hoursWorked,
    int? status,
  }) =>
      _repo.updateTaskProgress(
        taskItemId,
        progressId,
        progressPercentage: progressPercentage,
        loggedAt: loggedAt,
        notes: notes,
        hoursWorked: hoursWorked,
        status: status,
      );
}
