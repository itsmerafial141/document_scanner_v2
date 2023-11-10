import 'package:get/get.dart';

import '../modules/document_form/bindings/document_form_binding.dart';
import '../modules/document_form/views/document_form_view.dart';

// ignore_for_file: constant_identifier_names

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: _Paths.DOCUMENT_FORM,
      page: () => const DocumentFormView(),
      binding: DocumentFormBinding(),
    ),
    // GetPage(
    //   name: _Paths.CAMERA_SCANNER,
    //   page: () => const CameraScannerView(),
    //   binding: CameraScannerBinding(),
    // ),
  ];
}
