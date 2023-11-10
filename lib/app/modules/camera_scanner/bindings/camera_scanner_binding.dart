import 'package:get/get.dart';

import '../controllers/camera_scanner_controller.dart';

class CameraScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CameraScannerController>(
      () => CameraScannerController(),
    );
  }
}
