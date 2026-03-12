import 'package:task_tracking_mobile/features/core/domain/entities/label.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/label_repository.dart';

class CreateLabelUseCase {
  final LabelRepository repository;

  CreateLabelUseCase(this.repository);

  Future<Label> call({required String name, String? description}) =>
      repository.create(name: name, description: description);
}
