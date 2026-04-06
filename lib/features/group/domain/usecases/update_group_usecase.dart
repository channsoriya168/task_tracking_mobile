import 'package:task_tracking_mobile/features/group/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/group/domain/repositories/group_repository.dart';

class UpdateGroupUseCase {
  final GroupRepository repository;

  UpdateGroupUseCase(this.repository);

  Future<Group> call(
    String id, {
    required String name,
    String? color,
    String? description,
  }) =>
      repository.update(id, name: name, color: color, description: description);
}
