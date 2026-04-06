import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/task/domain/repositories/task_item_repository.dart';

class FetchTaskItemsUsecase {
  final TaskItemRepository _repository;

  FetchTaskItemsUsecase(this._repository);

  Future<List<TaskItem>> call({
    String? search,
    int? statusId,
    String? groupId,
    DateTime? SelectedDate,
  }) async {
    return await _repository.fetchTaskItems(
      search: search,
      statusId: statusId,
      groupId: groupId,
      SelectedDate: SelectedDate,
    );
  }
}