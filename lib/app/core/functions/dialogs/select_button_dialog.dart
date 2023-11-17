import 'package:document_scanner/app/core/functions/any_function.dart';
import 'package:document_scanner/app/core/themes/colors/app_colors_swatch.dart';
import 'package:document_scanner/app/core/themes/fonts/app_text_styles_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DialogSelectButton extends StatelessWidget {
  const DialogSelectButton({
    super.key,
    this.negativeTitle,
    this.positiveTitle,
    this.negativeOnPressed,
    this.positiveOnPressed,
  });

  final String? negativeTitle;
  final String? positiveTitle;

  final VoidCallback? negativeOnPressed;
  final VoidCallback? positiveOnPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Camera tidak tersedia",
          style: AppTextStyle.manropeBold16,
        ),
        16.h.verticalSpace,
        Row(
          children: [
            Expanded(
              child: MaterialButton(
                onPressed: negativeOnPressed ?? () => AnyFunction.getBack(),
                height: 50.h,
                elevation: 0,
                highlightElevation: 0,
                color: AppColorSwatch.DANGER,
                child: Text(
                  negativeTitle ?? "Tidak",
                  style: AppTextStyle.manropeBold14.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            16.h.horizontalSpace,
            Expanded(
              child: MaterialButton(
                onPressed: positiveOnPressed ?? () => AnyFunction.getBack(),
                height: 50.h,
                elevation: 0,
                highlightElevation: 0,
                color: AppColorSwatch.SUCCESS,
                child: Text(
                  positiveTitle ?? "Ya",
                  style: AppTextStyle.manropeBold14.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
