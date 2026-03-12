import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';
import 'package:task_tracking_mobile/features/auth/domain/repositories/auth_repository.dart';

class CheckAuthUsecase {
  final AuthRepository _repository;

  const CheckAuthUsecase(this._repository);

  Future<Auth> call() => _repository.checkAuth();
}