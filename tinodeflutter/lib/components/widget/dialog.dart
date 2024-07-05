
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../Constants/ColorConstants.dart';
import '../../app_text.dart';
import '../../global/app_colors.dart';

class AppDialog {
  static showAlertDialog(BuildContext context, Function() onConfirm, String title, String content,
      {String btnLabel = "", bool onBack = true}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0.0,
          contentPadding: const EdgeInsets.all(25),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const SizedBox(width: 24),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Image.asset('assets/image/ic_close.png', width: 24, height: 24))
                ],
              ),
              SizedBox(height: 10),
              Text(
                content,
                style: const TextStyle(
                  color: appColorText3,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFFBFBFBF), width: 1),
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
        );
      },
    );
  }

  static showImaegInfoDialog(BuildContext context, String extension, String size, int pixelX, int pixelY) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0.0,
          backgroundColor: ColorConstants.colorSub,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 25),
              AppText(
                text: "file_info_title".tr(),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 20,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppText(
                    text: "image_type".tr(),
                    fontSize: 16,
                  ),

                  AppText(
                    text: "${extension}",
                    fontSize: 16,
                  ),
                ],
              ),

              SizedBox(height: 10,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppText(
                    text: "image_size".tr(),
                    fontSize: 16,
                  ),

                  AppText(
                    text: "${size}",
                    fontSize: 16,
                  ),
                ],
              ),

              SizedBox(height: 10,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppText(
                    text: "image_resolution".tr(),
                    fontSize: 16,
                  ),

                  AppText(
                    text: "${pixelX}x${pixelY}",
                    fontSize: 16,
                  ),
                ],
              ),

              const SizedBox(height: 10),
            ],
          ),
          buttonPadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          actionsAlignment: MainAxisAlignment.start,
          actionsOverflowButtonSpacing: 1,
          actions: <Widget>[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 48,
                        decoration:
                        BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: ColorConstants.colorMain
                        ),
                        child: Center(
                          child: AppText(
                            text: "close".tr(),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static showConfirmDialog(BuildContext context, String title, String content, Function() onConfirm,
      {String confirmLabel = "", String cancelLabel = ""}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0.0,
          backgroundColor: ColorConstants.colorSub,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 25),
              if (title.isNotEmpty)
                Column(
                  children: [
                    AppText(
                      text: title,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 10,),

                    Container(
                      color: ColorConstants.white30Percent,
                      height: 0.3,
                    )
                  ],
                ),

              if (title.isNotEmpty) const SizedBox(height: 10),
              AppText(
                text: content,
                fontSize: 16,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),
            ],
          ),
          buttonPadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          actionsAlignment: MainAxisAlignment.start,
          actionsOverflowButtonSpacing: 1,
          actions: <Widget>[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 48,
                        decoration:
                            BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: ColorConstants.gray3
                            ),
                        child: Center(
                          child: AppText(
                            text: cancelLabel.isEmpty ? "cancel".tr() : cancelLabel,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
                      child: Container(
                        height: 48,
                        decoration:
                            BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: ColorConstants.colorMain
                            ),
                        child: Center(
                          child: AppText(
                            text: confirmLabel.isEmpty ? "confirm".tr() : confirmLabel,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static showOneDialog(BuildContext context, String title, String content, Function() onConfirm,
      {String confirmLabel = "", String cancelLabel = ""}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0.0,
          backgroundColor: ColorConstants.colorSub,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 25),
              if (title.isNotEmpty)
                Column(
                  children: [
                    AppText(
                      text: title,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 10,),

                    Container(
                      color: ColorConstants.white30Percent,
                      height: 0.3,
                    )
                  ],
                ),

              if (title.isNotEmpty) const SizedBox(height: 10),
              AppText(
                text: content,
                fontSize: 16,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
            ],
          ),
          buttonPadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          actionsAlignment: MainAxisAlignment.start,
          actionsOverflowButtonSpacing: 1,
          actions: <Widget>[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
                      child: Container(
                        height: 48,
                        decoration:
                        BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: ColorConstants.colorMain
                        ),
                        child: Center(
                          child: AppText(
                            text: confirmLabel.isEmpty ? "confirm".tr() : confirmLabel,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
