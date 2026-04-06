import 'package:task_tracking_mobile/features/profile/domain/repositories/profile_repository.dart';

class ChangePasswordUsecase {
  const ChangePasswordUsecase(this._repository);

  final ProfileRepository _repository;

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
