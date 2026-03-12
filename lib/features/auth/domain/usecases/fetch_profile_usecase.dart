import 'package:task_tracking_mobile/features/auth/domain/entities/employee_profile.dart';
import 'package:task_tracking_mobile/features/auth/domain/repositories/auth_repository.dart';

class FetchProfileUsecase {
  const FetchProfileUsecase(this._repository);

  final AuthRepository _repository;

  Future<EmployeeProfile?> call() => _repository.fetchProfile();
}
