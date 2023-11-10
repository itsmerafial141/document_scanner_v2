import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:document_scanner/app/core/functions/dialog_function.dart';
import 'package:document_scanner/app/modules/camera_scanner/views/camera_view.dart';
import 'package:document_scanner/app/modules/camera_scanner/views/cropping_preview.dart';
import 'package:document_scanner/app/modules/camera_scanner/views/image_view.dart';
import 'package:document_scanner/app/modules/camera_scanner/functions/edge_detector_function.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:document_scanner/app/core/enums/document_type_enum.dart';
import 'package:document_scanner/app/core/helper/rx_nullabel.dart';
import 'package:document_scanner/app/core/themes/fonts/app_text_styles_font.dart';
import 'package:document_scanner/app/modules/document_form/controllers/document_form_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_edge_detection/simple_edge_detection.dart';


class CameraScanner extends StatefulWidget {
  const CameraScanner.fromCamera({
    super.key,
    required this.docType,
  }) : imagePath = "";

  const CameraScanner.fromGrallery({
    super.key,
    required this.docType,
    required this.imagePath,
  });

  final DocumentType docType;
  final String imagePath;

  @override
  CameraScannerState createState() => CameraScannerState();
}

class CameraScannerState extends State<CameraScanner> {
  final docFormC = Get.find<DocumentFormController>();
  late CameraController controller;
  List<CameraDescription> cameras = [];
  String imagePath = "";
  String croppedImagePath = "";
  Rx<EdgeDetectionResult?> edgeDetectionResult =
      RxNullable<EdgeDetectionResult?>().setNull();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _initializeController();
    if (widget.imagePath.isNotEmpty) {
      _detectEdges(widget.imagePath);
    }
    super.initState();
  }

  void _initializeController() async {
    cameras = await availableCameras();

    controller = CameraController(
      cameras[0],
      ResolutionPreset.veryHigh,
      enableAudio: false,
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  void _onCropTapped() {
    if (croppedImagePath.isEmpty) {
      _processImage(imagePath, edgeDetectionResult.value!);
      return;
    }
    Get.back();
    setState(() {
      docFormC.setFileByDocType(widget.docType, croppedImagePath);
      docFormC.processedImage(widget.docType);
      imagePath = "";
      edgeDetectionResult.value = null;
      croppedImagePath = "";
    });
  }

  void _onRotateTapped() async {
    DialogFunctions.showLoading();
    var file = File(croppedImagePath);
    var fileByte = await file.readAsBytes();
    var image = img.decodeImage(fileByte);
    var rotatedImage = img.copyRotate(image!, angle: -90);
    // var rotatedByteImage = Uint8List.fromList(img.encodePng(rotatedImage));
    // var rotatedFileImage = await file.writeAsBytes(
    //   rotatedByteImage,
    //   flush: true,
    // );

    var rotatedFile = await _createFileFromString(
      base64Encode(
        Uint8List.fromList(
          img.encodePng(rotatedImage),
        ),
      ),
    );

    DialogFunctions.closeLoading();

    setState(() {
      croppedImagePath = rotatedFile.path;
    });
  }

  Future<File> _createFileFromString(value) async {
    final encodedStr = value;
    Uint8List bytes = base64.decode(encodedStr);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File(
      "$dir/${DateTime.now().millisecondsSinceEpoch}.png",
    );
    await file.writeAsBytes(bytes);
    return file;
  }

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
    if (croppedImagePath.isNotEmpty) {
      return ImageView(imagePath: croppedImagePath);
    }

    try {
      if (imagePath.isEmpty && edgeDetectionResult.value == null) {
        return CameraView(controller: controller);
      }
    } catch (e) {
      return const CircularProgressIndicator();
    }

    return ImagePreview(
      imagePath: imagePath,
      edgeDetectionResult: edgeDetectionResult.value,
    );
  }

  Widget _getButtonRow() {
    if (imagePath.isNotEmpty) {
      if (croppedImagePath.isNotEmpty) {
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              heroTag: "accept",
              backgroundColor: Colors.white54,
              elevation: 0,
              highlightElevation: 0,
              onPressed: _onCropTapped,
              child: const Icon(Icons.check_outlined, color: Colors.white),
            ),
            16.w.horizontalSpace,
            FloatingActionButton(
              heroTag: "rotate",
              backgroundColor: Colors.white54,
              elevation: 0,
              highlightElevation: 0,
              onPressed: _onRotateTapped,
              child: const Icon(
                Icons.rotate_90_degrees_ccw_rounded,
                color: Colors.white,
              ),
            ),
          ],
        );
      }
      return Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
          heroTag: "crop",
          backgroundColor: Colors.white54,
          elevation: 0,
          highlightElevation: 0,
          onPressed: _onCropTapped,
          child: const Icon(Icons.crop_rounded, color: Colors.white),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          heroTag: "camera",
          backgroundColor: Colors.white54,
          elevation: 0,
          highlightElevation: 0,
          onPressed: _onTakePictureButtonPressed,
          child: const Icon(Icons.camera_outlined, color: Colors.white),
        ),
        // const SizedBox(width: 16),
        // FloatingActionButton(
        //   heroTag: "gallery",
        //   foregroundColor: Colors.white,
        //   onPressed: _onGalleryButtonPressed,
        //   child: const Icon(Icons.image),
        // ),
      ],
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<String?> takePicture() async {
    if (!controller.value.isInitialized) {
      log('Error: select a camera first.');
      return null;
    }

    final Directory extDir = await getTemporaryDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';
    File? file = File(filePath);
    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      var picture = await controller.takePicture();
      file = await file.writeAsBytes(await picture.readAsBytes());
    } on CameraException catch (e) {
      log(e.toString());
      return null;
    }
    return file.path;
  }

  Future _detectEdges(String? filePath) async {
    if (!mounted || filePath == null) {
      return;
    }

    setState(() {
      imagePath = filePath;
    });

    EdgeDetectionResult result = await EdgeDetector().detectEdges(filePath);

    setState(() {
      edgeDetectionResult.value = result;
    });
  }

  Future _processImage(
    String filePath,
    EdgeDetectionResult edgeDetectionResult,
  ) async {
    if (!mounted) return;
    bool result = await EdgeDetector().processImage(
      filePath,
      edgeDetectionResult,
    );
    if (result == false) return;
    // Get.back();
    setState(() {
      imageCache.clearLiveImages();
      imageCache.clear();
      croppedImagePath = imagePath;
      // docFormC.setFileByDocType(widget.docType, croppedImagePath);
      // docFormC.processedImage(widget.docType);
    });
  }

  void _onTakePictureButtonPressed() async {
    String? filePath = await takePicture();

    log('Picture saved to $filePath');

    await _detectEdges(filePath);
  }

  // void _onGalleryButtonPressed() async {
  //   ImagePicker picker = ImagePicker();
  //   XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   final filePath = pickedFile!.path;

  //   log('Picture saved to $filePath');

  //   _detectEdges(filePath);
  // }

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
