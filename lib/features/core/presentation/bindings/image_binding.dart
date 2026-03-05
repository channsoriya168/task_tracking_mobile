import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/core/data/datasources/image_service.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/pick_and_compress_image_usecase.dart';

class ImageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ImageService());

    Get.lazyPut(() => PickAndCompressImageUseCase(Get.find()));
  }
}
