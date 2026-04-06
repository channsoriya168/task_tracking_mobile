import 'package:task_tracking_mobile/features/task/domain/repositories/task_item_repository.dart';

class AddTaskMemberUsecase {
  final TaskItemRepository _repository;
  AddTaskMemberUsecase(this._repository);

  Future<void> call(String taskItemId, String employeeId) =>
      _repository.addTaskMember(taskItemId, employeeId);
}