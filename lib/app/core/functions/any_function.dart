import 'package:document_scanner/app/core/functions/dialog_function.dart';
import 'package:get/get.dart';

class AnyFunction {
  static getBack() {
    DialogFunctions.closeDialog();
    DialogFunctions.closeBottomSheet();
    Get.back();
  }
}
