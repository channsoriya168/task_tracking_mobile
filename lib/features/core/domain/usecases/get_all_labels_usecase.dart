import 'package:task_tracking_mobile/features/core/domain/entities/label.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/label_repository.dart';

class GetAllLabelsUseCase {
  final LabelRepository repository;

  GetAllLabelsUseCase(this.repository);

  Future<List<Label>> call() => repository.getAll();
}
