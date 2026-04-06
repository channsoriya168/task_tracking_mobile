import 'package:task_tracking_mobile/features/label/domain/entities/label.dart';
import 'package:task_tracking_mobile/features/label/domain/repositories/label_repository.dart';

class UpdateLabelUseCase {
  final LabelRepository repository;

  UpdateLabelUseCase(this.repository);

  Future<Label> call(String id, {required String name, String? description}) =>
      repository.update(id, name: name, description: description);
}
