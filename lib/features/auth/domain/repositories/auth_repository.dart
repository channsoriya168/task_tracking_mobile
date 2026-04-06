import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';

abstract interface class AuthRepository {
  Future<Auth> login(String phoneNumber, String password);
  Future<void> logout();
  Future<Auth> refreshToken();
  Future<Auth> checkAuth();
}
