import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:task_tracking_mobile/features/core/data/datasources/image_service.dart';

class PickAndCompressImageUseCase {
  final ImageService service;

  PickAndCompressImageUseCase(this.service);

  Future<File?> call(ImageSource source) async {
    final picked = await service.pickImage(source);

    if (picked == null) return null;

    return await service.compressImage(picked);
  }
}
