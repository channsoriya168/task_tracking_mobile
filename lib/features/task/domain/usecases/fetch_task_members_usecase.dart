import 'package:task_tracking_mobile/features/task/domain/entities/task_member.dart';
import 'package:task_tracking_mobile/features/task/domain/repositories/task_item_repository.dart';

class FetchTaskMembersUsecase {
  final TaskItemRepository _repository;
  FetchTaskMembersUsecase(this._repository);

  Future<List<TaskMember>> call(String taskItemId) =>
      _repository.fetchTaskMembers(taskItemId);
}