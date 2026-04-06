import 'dart:io';

import 'package:task_tracking_mobile/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUsecase {
  const UpdateProfileUsecase(this._repository);

  final ProfileRepository _repository;

  Future<void> call({File? image, bool removeImage = false}) =>
      _repository.updateProfile(image: image, removeImage: removeImage);
}
