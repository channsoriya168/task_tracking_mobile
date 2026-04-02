import 'package:task_tracking_mobile/features/core/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/group_repository.dart';

class GetTaskGroupByIdUseCase {
  final TaskGroupRepository repository;

  GetTaskGroupByIdUseCase(this.repository);

  Future<TaskGroup> call(String id) => repository.getById(id);
}
