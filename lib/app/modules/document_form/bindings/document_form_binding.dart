import 'package:get/get.dart';

import '../controllers/document_form_controller.dart';

class DocumentFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DocumentFormController>(
      () => DocumentFormController(),
    );
  }
}
