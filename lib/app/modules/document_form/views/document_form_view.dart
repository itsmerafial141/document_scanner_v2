import 'dart:io';

import 'package:document_scanner/app/core/enums/document_type_enum.dart';
import 'package:document_scanner/app/core/themes/colors/app_colors_swatch.dart';
import 'package:document_scanner/app/core/themes/fonts/app_text_styles_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/document_form_controller.dart';

class DocumentFormView extends GetView<DocumentFormController> {
  const DocumentFormView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Document Scanner',
          style: AppTextStyle.manropeBold14.copyWith(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      body: SizedBox(
        height: Get.height,
        width: Get.width,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.topCenter,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColorSwatch.INFO,
                    AppColorSwatch.SUCCESS,
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: kToolbarHeight + Get.mediaQuery.viewPadding.top + 16.r,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16.r),
                ),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 24.h),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Document',
                      style: AppTextStyle.manropeBold20,
                    ),
                    16.h.verticalSpace,
                    RichText(
                      text: TextSpan(
                        style: AppTextStyle.manropeBold12,
                        children: [
                          const TextSpan(text: 'e-Ktp'),
                          TextSpan(
                            text: ' *',
                            style: AppTextStyle.manropeBold12.copyWith(
                              color: AppColorSwatch.DANGER,
                            ),
                          ),
                        ],
                      ),
                    ),
                    8.h.verticalSpace,
                    Row(
                      children: [
                        _documentButton(
                          onPressed: () {
                            // controller.getImageWithCropper(
                            //   ImageFrom.CAMERA,
                            //   DocumentType.eKTP,
                            // );
                            controller.onTakePictureTapped(
                              source: ImageSource.camera,
                              docType: DocumentType.eKTP,
                            );
                          },
                          title: "Foto Dokumen",
                          icon: Icons.camera_alt_outlined,
                        ),
                        8.h.horizontalSpace,
                        _documentButton(
                          onPressed: () {
                            controller.onTakePictureTapped(
                              source: ImageSource.gallery,
                              docType: DocumentType.eKTP,
                            );
                          },
                          title: "Unggah Dokumen",
                          icon: Icons.add_rounded,
                        ),
                      ],
                    ),
                    Obx(() {
                      if (controller.selectedImageEktp.value != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            8.h.verticalSpace,
                            InkWell(
                              onTap: () => controller.isEktpPreviewed.toggle(),
                              child: Text(
                                "(preview)",
                                style: AppTextStyle.manropeSemibold12.copyWith(
                                  color: controller.isEktpValid.value
                                      ? AppColorSwatch.SUCCESS
                                      : AppColorSwatch.DANGER,
                                ),
                              ),
                            ),
                            if (controller.isEktpPreviewed.value)
                              SizedBox(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    8.h.verticalSpace,
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: Image.file(
                                        File(
                                          controller
                                              .selectedImageEktp.value!.path,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      } else {
                        return const SizedBox();
                      }
                    }),
                    16.h.verticalSpace,
                    RichText(
                      text: TextSpan(
                        style: AppTextStyle.manropeBold12,
                        children: [
                          const TextSpan(text: 'Kartu Keluarga'),
                          TextSpan(
                            text: ' *',
                            style: AppTextStyle.manropeBold12.copyWith(
                              color: AppColorSwatch.DANGER,
                            ),
                          ),
                        ],
                      ),
                    ),
                    8.h.verticalSpace,
                    Row(
                      children: [
                        _documentButton(
                          onPressed: () {
                            controller.onTakePictureTapped(
                              source: ImageSource.camera,
                              docType: DocumentType.KK,
                            );
                          },
                          title: "Foto Dokumen",
                          icon: Icons.camera_alt_outlined,
                        ),
                        8.h.horizontalSpace,
                        _documentButton(
                          onPressed: () {
                            controller.onTakePictureTapped(
                              source: ImageSource.gallery,
                              docType: DocumentType.KK,
                            );
                          },
                          title: "Unggah Dokumen",
                          icon: Icons.add_rounded,
                        ),
                      ],
                    ),
                    Obx(() {
                      if (controller.selectedImage.value != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            8.h.verticalSpace,
                            InkWell(
                              onTap: () => controller.isKkPreviewed.toggle(),
                              child: Text(
                                "(preview)",
                                style: AppTextStyle.manropeSemibold12.copyWith(
                                  color: controller.isKKValid.value
                                      ? AppColorSwatch.SUCCESS
                                      : AppColorSwatch.DANGER,
                                ),
                              ),
                            ),
                            if (controller.isKkPreviewed.value)
                              SizedBox(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    8.h.verticalSpace,
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: Image.file(
                                        controller.selectedImage.value!,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      } else {
                        return const SizedBox();
                      }
                    }),
                    16.h.verticalSpace,
                    RichText(
                      text: TextSpan(
                        style: AppTextStyle.manropeBold12,
                        children: [
                          const TextSpan(
                            text:
                                'Akta Kelahiran/Ijazah/Akta Perkawinan/Buku Nikah/Surat Baptis',
                          ),
                          TextSpan(
                            text: ' * ',
                            style: AppTextStyle.manropeBold12.copyWith(
                              color: AppColorSwatch.DANGER,
                            ),
                          ),
                          WidgetSpan(
                            child: InkWell(
                              onTap: () {},
                              child: Icon(
                                Icons.info,
                                color: AppColorSwatch.DISABLE.shade500,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    8.h.verticalSpace,
                    Row(
                      children: [
                        _documentButton(
                          onPressed: () {
                            controller.onTakePictureTapped(
                              source: ImageSource.camera,
                              docType: DocumentType.OTHER,
                            );
                          },
                          title: "Foto Dokumen",
                          icon: Icons.camera_alt_outlined,
                        ),
                        8.h.horizontalSpace,
                        _documentButton(
                          onPressed: () {
                            controller.onTakePictureTapped(
                              source: ImageSource.gallery,
                              docType: DocumentType.OTHER,
                            );
                          },
                          title: "Unggah Dokumen",
                          icon: Icons.add_rounded,
                        ),
                      ],
                    ),
                    Obx(() {
                      if (controller.selectedImageOther.value != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            8.h.verticalSpace,
                            InkWell(
                              onTap: () => controller.isOtherPreviewed.toggle(),
                              child: Text(
                                "(preview)",
                                style: AppTextStyle.manropeSemibold12.copyWith(
                                  color: controller.isOtherValid.value
                                      ? AppColorSwatch.SUCCESS
                                      : AppColorSwatch.DANGER,
                                ),
                              ),
                            ),
                            if (controller.isOtherPreviewed.value)
                              SizedBox(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    8.h.verticalSpace,
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: Image.file(
                                        controller.selectedImageOther.value!,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      } else {
                        return const SizedBox();
                      }
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => controller.onUploadDocumentTapped(context),
      //   child: const Icon(Icons.upload_file_outlined),
      // ),
    );
  }

  Widget _documentButton({
    VoidCallback? onPressed,
    required String title,
    required IconData icon,
  }) {
    return Expanded(
      child: MaterialButton(
        onPressed: onPressed,
        elevation: 0,
        highlightElevation: 0,
        height: 45.h,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
          side: const BorderSide(
            width: 1,
            color: AppColorSwatch.INFO,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.start,
                style: AppTextStyle.manropeSemibold10,
              ),
            ),
            8.h.horizontalSpace,
            Icon(
              icon,
              color: AppColorSwatch.TEXT,
            ),
          ],
        ),
      ),
    );
  }
}
