import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key, required this.controller});

  final CameraController? controller;

  @override
  Widget build(BuildContext context) {
    return _getCameraPreview();
  }

  Widget _getCameraPreview() {
    if (controller == null || !controller!.value.isInitialized) {
      return Container();
    }

    final scale = 1 /
        (controller!.value.aspectRatio *
            (Get.width / (Get.height - kToolbarHeight)));
    return Stack(
      fit: StackFit.expand,
      children: [
        Wrap(
          children: [
            Transform.scale(
              scale: scale,
              alignment: Alignment.topCenter,
              child: CameraPreview(controller!),
            ),
          ],
        ),
      ],
    );
  }
}
