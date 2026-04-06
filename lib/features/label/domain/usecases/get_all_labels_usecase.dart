import 'package:task_tracking_mobile/features/label/domain/entities/label.dart';
import 'package:task_tracking_mobile/features/label/domain/repositories/label_repository.dart';

class GetAllLabelsUseCase {
  final LabelRepository repository;

  GetAllLabelsUseCase(this.repository);

  Future<List<Label>> call() => repository.getAll();
}
