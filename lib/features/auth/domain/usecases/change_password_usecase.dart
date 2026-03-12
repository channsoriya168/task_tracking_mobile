import 'package:task_tracking_mobile/features/auth/domain/repositories/auth_repository.dart';

class ChangePasswordUsecase {
  final AuthRepository _repository;

  const ChangePasswordUsecase(this._repository);

  Future<void> call({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) => _repository.changePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
    confirmNewPassword: confirmNewPassword,
  );
}