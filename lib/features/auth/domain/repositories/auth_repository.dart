import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/qr_code.dart';

abstract interface class AuthRepository {
  Future<void> logout();
  Future<Auth> refreshToken();
  Future<Auth> checkAuth();
  Future<Auth> qrLogin(String token);
  Future<QrLoginData> generateQrLogin(String employeeId);
}
