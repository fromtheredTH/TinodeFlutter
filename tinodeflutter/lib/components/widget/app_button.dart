
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:tinodeflutter/Constants/FontConstants.dart';

import '../../Constants/ColorConstants.dart';

// 앱 고유 텍스트
class AppButton extends StatelessWidget {
  TextDecoration? textDecoration;
  String text;
  Color? textColor;
  Color? disableTextColor;
  Color? color;
  Color? disableColor;
  double? fontSize;
  FontWeight? fontWeight;
  String? fontFamily;
  TextAlign? textAlign;
  TextOverflow? overflow;
  Function() onTap;
  int? maxLine;
  double? margin;
  double? height;
  double? width;
  bool? disabled;

  AppButton({Key? key,
    required this.text,
    this.color,
    this.disableTextColor,
    this.disableColor,
    this.fontFamily,
    this.height,
    this.textAlign,
    this.overflow,
    this.maxLine,
    this.margin,
    required this.onTap,
    this.width,
    this.textColor,
    this.disabled,
    this.fontSize,
    this.textDecoration})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width ?? double.infinity,
        height: height ?? 48,
        margin: EdgeInsets.only(
            left: margin ?? 16, right: margin ?? 16),
        decoration: BoxDecoration(
            color: disabled ?? false ? disableColor ?? ColorConstants.gray3 : color ?? ColorConstants.colorMain,
            borderRadius: BorderRadius.circular(10)
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: Material(
              color: disabled ?? false ? disableColor ?? ColorConstants.gray3 : color ?? ColorConstants.colorMain,
              child: InkWell(
                onTap: disabled ?? false ? (){} : onTap,
                child: Center(
                  child: Text(
                    text,
                    textAlign: textAlign ?? TextAlign.center,
                    overflow: overflow,
                    maxLines: maxLine,
                    style: TextStyle(
                      decoration: textDecoration ?? TextDecoration.none,
                      fontFamily: FontConstants.AppFont,
                      fontWeight: fontWeight ?? FontWeight.w700,
                      fontSize: fontSize ?? 16,
                      color: disabled ?? false ? disableTextColor ?? Colors.white : textColor ?? Colors.white,
                    ),
                  ),
                )
              ),
            )
        )
    );
  }
}