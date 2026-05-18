import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:task_tracking_mobile/core/services/image_service.dart';

class PickAndCompressImageHelper {
  final ImageService service;

  PickAndCompressImageHelper(this.service);

  Future<File?> call(ImageSource source) async {
    final picked = await service.pickImage(source);

    if (picked == null) return null;

    return await service.compressImage(picked);
  }
}
