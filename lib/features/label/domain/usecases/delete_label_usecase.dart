import 'package:task_tracking_mobile/features/label/domain/repositories/label_repository.dart';

class DeleteLabelUseCase {
  final LabelRepository repository;

  DeleteLabelUseCase(this.repository);

  Future<void> call(String id) => repository.delete(id);
}
