import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';
import 'package:task_tracking_mobile/features/auth/domain/repositories/auth_repository.dart';

class RefreshTokenUsecase {
  const RefreshTokenUsecase(this._repository);

  final AuthRepository _repository;

  Future<Auth> call() => _repository.refreshToken();
}