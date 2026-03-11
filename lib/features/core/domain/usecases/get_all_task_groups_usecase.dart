import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_group_repository.dart';

class GetAllTaskGroupsUseCase {
  final TaskGroupRepository repository;

  GetAllTaskGroupsUseCase(this.repository);

  Future<List<TaskGroup>> call() => repository.getAll();
}
