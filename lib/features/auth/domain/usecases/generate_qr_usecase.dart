import 'package:task_tracking_mobile/features/auth/domain/entities/qr_code.dart';
import 'package:task_tracking_mobile/features/auth/domain/repositories/auth_repository.dart';

class GenerateQrUsecase {
  const GenerateQrUsecase(this._repository);

  final AuthRepository _repository;

  Future<QrLoginData> call(String employeeId) =>
      _repository.generateQrLogin(employeeId);
}