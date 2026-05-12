import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';
import 'package:task_tracking_mobile/features/auth/domain/repositories/auth_repository.dart';

class QrLoginUsecase {
  const QrLoginUsecase(this._repository);

  final AuthRepository _repository;

  Future<Auth> call(String token) => _repository.qrLogin(token);
}