import 'package:document_scanner/app/modules/camera_scanner/controllers/camera_scanner_controller.dart';
import 'package:document_scanner/app/modules/camera_scanner/views/camera_view.dart';
import 'package:document_scanner/app/modules/camera_scanner/views/cropping_preview.dart';
import 'package:document_scanner/app/modules/camera_scanner/views/image_view.dart';
import 'package:document_scanner/app/core/themes/fonts/app_text_styles_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CameraScannerView extends GetView<CameraScannerController> {
  const CameraScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        shadowColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        title: Text(
          'Ambil Gambar Document',
          style: AppTextStyle.manropeBold14.copyWith(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          _getMainWidget(),
          _getBottomBar(),
        ],
      ),
    );
  }

  Widget _getMainWidget() {
    return controller.obx(
      (camController) {
        if (controller.isImagePreview) {
          return ImageView(imagePath: controller.croppedImagePath);
        }

        if (controller.isCameraView) {
          return CameraView(controller: camController);
        }

        return ImagePreview(
          imagePath: controller.imagePath,
          edgeDetectionResult: controller.edgeDetectionResult.value,
        );
      },
      onLoading: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _getButtonRow() {
    return GetBuilder<CameraScannerController>(
      init: CameraScannerController(),
      builder: (controller) {
        return Column(
          children: [
            if (controller.isImagePreview) _imagePreviewButton(controller),
            if (controller.isCroppedView) _croppedButton(controller),
            if (controller.isCameraView) _cameraButton(controller),
          ],
        );
      },
    );
  }

  Row _cameraButton(CameraScannerController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          heroTag: "camera",
          backgroundColor: Colors.white54,
          elevation: 0,
          highlightElevation: 0,
          onPressed: controller.onTakePictureButtonPressed,
          child: const Icon(Icons.camera_outlined, color: Colors.white),
        ),
      ],
    );
  }

  Align _croppedButton(CameraScannerController controller) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FloatingActionButton(
        heroTag: "crop",
        backgroundColor: Colors.white54,
        elevation: 0,
        highlightElevation: 0,
        onPressed: controller.onCropTapped,
        child: const Icon(Icons.crop_rounded, color: Colors.white),
      ),
    );
  }

  Row _imagePreviewButton(CameraScannerController controller) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          heroTag: "accept",
          backgroundColor: Colors.white54,
          elevation: 0,
          highlightElevation: 0,
          onPressed: controller.onAcceptTapped,
          child: const Icon(Icons.check_outlined, color: Colors.white),
        ),
        16.w.horizontalSpace,
        FloatingActionButton(
          heroTag: "rotate",
          backgroundColor: Colors.white54,
          elevation: 0,
          highlightElevation: 0,
          onPressed: controller.onRotateTapped,
          child: const Icon(
            Icons.rotate_90_degrees_ccw_rounded,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Padding _getBottomBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: _getButtonRow(),
      ),
    );
  }
}
