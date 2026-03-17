import 'package:task_tracking_mobile/features/core/domain/repositories/task_item_repository.dart';

class CreateTaskProgressUsecase {
  final TaskItemRepository _repo;
  const CreateTaskProgressUsecase(this._repo);

  Future<void> call(
    String taskItemId, {
    required int progressPercentage,
    required DateTime loggedAt,
    String? notes,
    double? hoursWorked,
    int? status,
  }) =>
      _repo.createTaskProgress(
        taskItemId,
        progressPercentage: progressPercentage,
        loggedAt: loggedAt,
        notes: notes,
        hoursWorked: hoursWorked,
        status: status,
      );
}
