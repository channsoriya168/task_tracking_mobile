import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';
import 'package:task_tracking_mobile/features/auth/domain/repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository _repository;

  const LoginUsecase(this._repository);

  Future<Auth> call(String phoneNumber, String password) =>
      _repository.login(phoneNumber, password);
}
