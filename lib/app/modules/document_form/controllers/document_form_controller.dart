import 'dart:io';
import 'dart:ui';

import 'package:document_scanner/app/core/enums/document_type_enum.dart';
import 'package:document_scanner/app/core/extensions/document_extension.dart';
import 'package:document_scanner/app/core/functions/dialog_function.dart';
import 'package:document_scanner/app/core/helper/rx_nullabel.dart';
import 'package:document_scanner/app/modules/camera_scanner/views/camera_scanner_view.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_edge_detection/simple_edge_detection.dart';

class DocumentFormController extends GetxController {
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  late Rx<File?> selectedImage;
  late Rx<File?> selectedImageEktp;
  late Rx<File?> selectedImageOther;
  late Rx<InputImage?> selectedInputImage;

  late RxBool isKkPreviewed;
  late RxBool isEktpPreviewed;
  late RxBool isOtherPreviewed;
  late RxBool isEktpValid;
  late RxBool isKKValid;
  late RxBool isOtherValid;

  String getDialogErrorMessage(DocumentType docType) {
    switch (docType) {
      case DocumentType.eKTP:
        return "Format e-KTP tidak sesuai!";
      case DocumentType.KK:
        return "Format kartu keluarga tidak sesuai!";
      default:
        return "Format document tidak sesuai!";
    }
  }

  String getDialogSuccessMessage(DocumentType docType) {
    switch (docType) {
      case DocumentType.eKTP:
        return "Dokumen e-KTP berhasil diupload!";
      case DocumentType.KK:
        return "Dokumen kartu keluarga berhasil diupload!";
      case DocumentType.AKTA_KELAHIRAN:
        return "Dokumen akta kelahiran berhasil diupload!";
      case DocumentType.IJAZAH:
        return "Dokumen ijazah berhasil diupload!";
      case DocumentType.AKTA_PERKAWINAN:
        return "Dokumen akta perkawinan berhasil diupload!";
      case DocumentType.BUKU_NIKAH:
        return "Dokumen buku nikah berhasil diupload!";
      case DocumentType.SURAT_BAPTIS:
        return "Dokumen surat baptis berhasil diupload!";
      default:
        return "Dokumen berhasil diupload!";
    }
  }

  File getFileByDocType(DocumentType docType) {
    switch (docType) {
      case DocumentType.eKTP:
        return selectedImageEktp.value!;
      case DocumentType.KK:
        return selectedImage.value!;
      default:
        return selectedImageOther.value!;
    }
  }

  void setFileByDocType(DocumentType docType, String croppedImagePath) {
    switch (docType) {
      case DocumentType.eKTP:
        selectedImageEktp.value = File(croppedImagePath);
        break;
      case DocumentType.KK:
        selectedImage.value = File(croppedImagePath);
        break;
      default:
        selectedImageOther.value = File(croppedImagePath);
        break;
    }
  }

  @override
  void dispose() {
    selectedImage.close();
    selectedImageEktp.close();
    selectedImageOther.close();
    selectedInputImage.close();
    isKkPreviewed.close();
    isEktpPreviewed.close();
    isOtherPreviewed.close();
    isEktpValid.close();
    isKKValid.close();
    isOtherValid.close();
    super.dispose();
  }

  @override
  void onInit() {
    selectedImage = RxNullable<File?>().setNull();
    selectedImageEktp = RxNullable<File?>().setNull();
    selectedImageOther = RxNullable<File?>().setNull();
    selectedInputImage = RxNullable<InputImage?>().setNull();

    isKkPreviewed = false.obs;
    isEktpPreviewed = false.obs;
    isOtherPreviewed = false.obs;

    isEktpValid = false.obs;
    isKKValid = false.obs;
    isOtherValid = false.obs;
    super.onInit();
  }

  void converterImage(String imagePath, DocumentType docType) async {}

  void _processedEktpImage(
    InputImage inputImage,
    DocumentType docType,
  ) async {
    DialogFunctions.showLoading();
    final visionText = await textRecognizer.processImage(inputImage);
    DialogFunctions.closeLoading();
    Rect? nikRect;
    bool isNikDetected = false;
    for (var block in visionText.blocks) {
      for (var line in block.lines) {
        for (var element in line.elements) {
          if (element.text.isEktp) {
            nikRect = element.boundingBox;
          }
        }
      }
    }
    for (var block in visionText.blocks) {
      for (var line in block.lines) {
        for (var element in line.elements) {
          if (nikRect != null) {
            if (element.boundingBox.center.dy >= nikRect.top &&
                element.boundingBox.center.dy <= nikRect.bottom &&
                element.boundingBox.left >= nikRect.right) {
              if (element.text.length == 16) {
                isNikDetected = true;
              }
            }
          }
        }
      }
    }
    DialogFunctions.closeLoading();
    if (isNikDetected && visionText.text.toLowerCase().contains("provinsi")) {
      isEktpValid.value = true;
      DialogFunctions.showSuccess(
        message: getDialogSuccessMessage(docType),
        onPressed: () => DialogFunctions.closeDialog(),
      );
    } else {
      isEktpValid.value = false;
      DialogFunctions.showProblem(
        message: getDialogErrorMessage(docType),
        onPressed: () => DialogFunctions.closeDialog(),
      );
    }
  }

  void onTakePictureTapped({
    required ImageSource source,
    required DocumentType docType,
  }) {
    if (source == ImageSource.camera) {
      Get.to(() => CameraScanner.fromCamera(docType: docType));
    } else {
      _takePictureFromGallery(docType);
    }
  }

  void _takePictureFromGallery(DocumentType docType) async {
    final ImagePicker picker = ImagePicker();
    var xFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (xFile == null) return;
    Get.to(() {
      return CameraScanner.fromGrallery(
        docType: docType,
        imagePath: xFile.path,
      );
    });
  }

  void cropImage(
    DocumentType docType,
    EdgeDetectionResult result,
  ) async {}

  void processedImage(DocumentType docType) async {
    var inputImage = InputImage.fromFile(getFileByDocType(docType));
    if (docType == DocumentType.eKTP) {
      _processedEktpImage(inputImage, docType);
    } else {
      DialogFunctions.showLoading();
      var recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      DialogFunctions.closeLoading();
      bool isDocumentValid = false;
      var documentType = docType;
      for (TextBlock block in recognizedText.blocks) {
        if (docType == DocumentType.KK) {
          if (block.text.isKartuKeluarga) {
            isDocumentValid = true;
            isKKValid.value = true;
            documentType = DocumentType.KK;
            break;
          } else {
            isKKValid.value = false;
          }
        } else {
          if (block.text.isAkteKelahiran) {
            isDocumentValid = true;
            isOtherValid.value = true;
            documentType = DocumentType.AKTA_KELAHIRAN;
            break;
          } else if (block.text.isIjazah) {
            isDocumentValid = true;
            isOtherValid.value = true;
            documentType = DocumentType.IJAZAH;
            break;
          } else if (block.text.isAktaPerkawinan) {
            isDocumentValid = true;
            isOtherValid.value = true;
            documentType = DocumentType.AKTA_PERKAWINAN;
            break;
          } else if (block.text.isBukuNikah) {
            isDocumentValid = true;
            isOtherValid.value = true;
            documentType = DocumentType.BUKU_NIKAH;
            break;
          } else if (block.text.isSuratBaptis) {
            isDocumentValid = true;
            isOtherValid.value = true;
            documentType = DocumentType.SURAT_BAPTIS;
            break;
          } else {
            isOtherValid.value = false;
            isDocumentValid = false;
          }
        }
      }

      DialogFunctions.closeLoading();
      if (isDocumentValid) {
        DialogFunctions.showSuccess(
          message: getDialogSuccessMessage(documentType),
          onPressed: () => DialogFunctions.closeDialog(),
        );
      } else {
        DialogFunctions.showProblem(
          message: getDialogErrorMessage(documentType),
          onPressed: () => DialogFunctions.closeDialog(),
        );
      }
    }
  }
}
