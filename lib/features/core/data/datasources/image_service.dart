import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 100,
    );

    if (file == null) return null;

    return File(file.path);
  }

  Future<File?> compressImage(File file) async {
    final targetPath = "${file.path}_compressed.jpg";

    final XFile? compressed = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
    );

    if (compressed == null) return null;

    return File(compressed.path);
  }
}
