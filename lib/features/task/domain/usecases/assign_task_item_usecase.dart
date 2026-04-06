import 'package:task_tracking_mobile/features/task/domain/repositories/task_item_repository.dart';

class AssignTaskItemUsecase {
  final TaskItemRepository _repository;
  AssignTaskItemUsecase(this._repository);

  Future<void> call(String taskId, String assignedToId) =>
      _repository.assignTask(taskId, assignedToId);
}