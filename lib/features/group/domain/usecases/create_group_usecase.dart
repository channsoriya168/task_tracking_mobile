import 'package:task_tracking_mobile/features/group/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/group/domain/repositories/group_repository.dart';

class CreateGroupUseCase {
  final GroupRepository repository;

  CreateGroupUseCase(this.repository);

  Future<Group> call({
    required String name,
    String? color,
    String? description,
  }) => repository.create(name: name, color: color, description: description);
}
