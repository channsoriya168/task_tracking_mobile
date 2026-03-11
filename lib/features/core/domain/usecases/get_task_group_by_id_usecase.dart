import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_group_repository.dart';

class GetTaskGroupByIdUseCase {
  final TaskGroupRepository repository;

  GetTaskGroupByIdUseCase(this.repository);

  Future<TaskGroup> call(String id) => repository.getById(id);
}
