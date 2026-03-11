import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_group_repository.dart';

class CreateTaskGroupUseCase {
  final TaskGroupRepository repository;

  CreateTaskGroupUseCase(this.repository);

  Future<TaskGroup> call({
    required String name,
    String? color,
    String? description,
  }) =>
      repository.create(name: name, color: color, description: description);
}
