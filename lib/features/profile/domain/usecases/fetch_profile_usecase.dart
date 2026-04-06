import 'package:task_tracking_mobile/features/profile/domain/entities/employee_profile.dart';
import 'package:task_tracking_mobile/features/profile/domain/repositories/profile_repository.dart';

class FetchProfileUsecase {
  const FetchProfileUsecase(this._repository);

  final ProfileRepository _repository;

  Future<EmployeeProfile?> call() => _repository.fetchProfile();
}
