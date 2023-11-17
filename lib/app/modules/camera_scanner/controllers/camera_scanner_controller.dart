import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:document_scanner/app/core/enums/document_type_enum.dart';
import 'package:document_scanner/app/core/functions/any_function.dart';
import 'package:document_scanner/app/core/functions/dialog_function.dart';
import 'package:document_scanner/app/core/helper/rx_nullabel.dart';
import 'package:document_scanner/app/modules/camera_scanner/enums/document_source_enum.dart';
import 'package:document_scanner/app/modules/document_form/controllers/document_form_controller.dart';
import 'package:document_scanner/edge_detector_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_edge_detection/simple_edge_detection.dart';

class CameraScannerController extends GetxController
    with StateMixin<CameraController> {
  final docFormC = Get.find<DocumentFormController>();

  late CameraController _cameraController;
  late List<CameraDescription> cameras;
  late String imagePath;
  late String croppedImagePath;
  late Rx<EdgeDetectionResult?> edgeDetectionResult;

  //? ARGUMENT VARIABLE
  late DocumentSources? _documentSource;
  late DocumentType? _documentType;

  String get timestamp => DateTime.now().millisecondsSinceEpoch.toString();

  bool get isImagePreview =>
      imagePath.isNotEmpty && croppedImagePath.isNotEmpty;

  bool get isCameraView =>
      imagePath.isEmpty && edgeDetectionResult.value == null;

  bool get isCroppedView => imagePath.isNotEmpty && croppedImagePath.isEmpty;

  @override
  void dispose() {
    _cameraController.dispose();
    cameras.clear();
    edgeDetectionResult.close();
    super.dispose();
  }

  @override
  void onInit() {
    _initializeData();
    _initializeArguments();
    _initializeCameras();
    super.onInit();
  }

  void _initializeData() {
    cameras = [];
    imagePath = "";
    croppedImagePath = "";
    edgeDetectionResult = RxNullable<EdgeDetectionResult?>().setNull();
  }

  void _initializeArguments() {
    _documentType = Get.arguments['documentType'];
    _documentSource = Get.arguments['documentSource'];
    imagePath = Get.arguments['imagePath'];

    if (_documentType == null) {
      throw (Exception('Anda belum mengisi argument [DocumentType]'));
    }
    if (_documentSource == null) {
      throw (Exception('Anda belum mengisi argument [DocumentSources]'));
    }

    if (_documentSource == DocumentSources.GALLERY) {
      if (imagePath.isEmpty) {
        throw (Exception('Anda belum mengisi argument [IMAGE PATH]'));
      }
    }
  }

  void _initializeCameras() async {
    cameras = await availableCameras();

    if (cameras.isEmpty) {
      DialogFunctions.showProblem(
        onPressed: () => AnyFunction.getBack(),
      );
    }
    cameras = await availableCameras();
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.veryHigh,
      enableAudio: false,
    );
    _cameraController.initialize().then((_) {
      change(_cameraController, status: RxStatus.success());
    }).onError((_, stackTrace) {
      stackTrace.printError();
      change(null, status: RxStatus.error("Camera error when initializing"));
    });
  }

  void onCropTapped() {
    if (croppedImagePath.isEmpty) {
      _processImage(imagePath, edgeDetectionResult.value!);
      return;
    }
    Get.back();
    docFormC.setFileByDocType(_documentType!, croppedImagePath);
    docFormC.processedImage(_documentType!);
    imagePath = "";
    edgeDetectionResult.value = null;
    croppedImagePath = "";
  }

  void onAcceptTapped() {
    if (croppedImagePath.isEmpty) {
      _processImage(imagePath, edgeDetectionResult.value!);
      return;
    }
  }

  void onTakePictureButtonPressed() async {
    String? filePath = await takePicture();
    await _detectEdges(filePath);
  }

  void onRotateTapped() async {
    change(null, status: RxStatus.loading());
    var file = File(croppedImagePath);
    var fileByte = await file.readAsBytes();
    var image = img.decodeImage(fileByte);
    var rotatedImage = img.copyRotate(image!, angle: -90);
    var rotatedFile = await _createFileFromString(
      base64Encode(
        Uint8List.fromList(
          img.encodePng(rotatedImage),
        ),
      ),
    );
    change(_cameraController, status: RxStatus.success());

    croppedImagePath = rotatedFile.path;
    update();
  }

  Future<String?> takePicture() async {
    final Directory extDir = await getTemporaryDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/$timestamp.jpg';
    File? file = File(filePath);
    if (_cameraController.value.isTakingPicture) {
      return null;
    }

    try {
      var picture = await _cameraController.takePicture();
      file = await file.writeAsBytes(await picture.readAsBytes());
    } on CameraException catch (e) {
      e.printError();
      return null;
    }
    return file.path;
  }

  Future _detectEdges(String? filePath) async {
    if (filePath == null) return;
    imagePath = filePath;
    update();
    EdgeDetectionResult result = await EdgeDetector().detectEdges(filePath);
    edgeDetectionResult.value = result;
    update();
  }

  Future _processImage(
    String filePath,
    EdgeDetectionResult edgeDetectionResult,
  ) async {
    bool result = await EdgeDetector().processImage(
      filePath,
      edgeDetectionResult,
    );
    if (result == false) return;
    imageCache.clearLiveImages();
    imageCache.clear();
    croppedImagePath = imagePath;
    update();
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
}
