import 'package:task_tracking_mobile/features/core/domain/repositories/task_item_repository.dart';

class RemoveTaskMemberUsecase {
  final TaskItemRepository _repository;
  RemoveTaskMemberUsecase(this._repository);

  Future<void> call(String taskItemId, String memberId) =>
      _repository.removeTaskMember(taskItemId, memberId);
}
