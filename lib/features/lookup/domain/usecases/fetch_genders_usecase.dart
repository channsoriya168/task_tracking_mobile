import 'package:task_tracking_mobile/features/lookup/domain/entities/lookup_gender.dart';
import 'package:task_tracking_mobile/features/lookup/domain/repositories/lookup_repository.dart';

class FetchGendersUsecase {
  final LookupRepository _repository;

  FetchGendersUsecase(this._repository);

  Future<List<LookupGender>> call() => _repository.fetchGenders();
}
