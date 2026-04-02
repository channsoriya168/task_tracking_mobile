import 'package:task_tracking_mobile/features/core/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/group_repository.dart';

class UpdateTaskGroupUseCase {
  final TaskGroupRepository repository;

  UpdateTaskGroupUseCase(this.repository);

  Future<TaskGroup> call(
    String id, {
    required String name,
    String? color,
    String? description,
  }) =>
      repository.update(id, name: name, color: color, description: description);
}
