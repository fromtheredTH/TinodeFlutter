import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:tinodeflutter/Constants/FontConstants.dart';
class AppTextField extends StatelessWidget {
  final TextEditingController? textController;
  final TextInputAction? textInputAction;
  final TextInputType? keyBoardType;
  final AutovalidateMode? autoValidateMode;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? suffix;
  final Color textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool? obscureText;
  final bool? isCursorEnable;
  final VoidCallback? callbackSuffix;
  final FormFieldValidator<String>? validator;
  bool? readOnly;
  int? minChar;
  final ValueChanged<String>? onChanged;
  final Color? textBorderColor;
  final Color? textFieldLight;
  final Color? textFieldDark;
  final Color? textColorHint;
  final Color? fillColor;
  final Color? enableBorderColor;
  final double? radious;
  final double? radiousFouse;

  AppTextField(
      {
        Key? key,
      this.keyBoardType,
      this.autoValidateMode,
      this.textInputAction,
        this.textController,
      required this.hintText,
      this.prefixIcon,
      this.suffixIcon,
      required this.textColor,
      this.obscureText,
      this.callbackSuffix,
      this.suffix,
      this.validator,
      this.readOnly,
      this.isCursorEnable,
      this.minChar,
        this.fontSize,
        this.fontWeight,
      this.onChanged,
      this.textBorderColor,
      this.textFieldLight,
      this.textFieldDark,
      this.textColorHint,this.fillColor,this.enableBorderColor,this.radious,this.radiousFouse})
      : super(key: key);



  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyBoardType,
      readOnly: readOnly ?? false,
      textAlign: TextAlign.start,
      enabled: isCursorEnable ?? true,
      maxLength: minChar,
      autovalidateMode: autoValidateMode,
      validator: validator,
      textInputAction: textInputAction,

      onChanged: onChanged,
      obscureText: obscureText ?? false,
      controller: textController,
      style: TextStyle(
        fontFamily:  FontConstants.AppFont,
        color: textColor ?? Colors.white,
        fontSize: fontSize ?? 14,
        fontWeight: fontWeight ?? FontWeight.w400,
      ),
      decoration: InputDecoration(
        counterText: '',
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily:  FontConstants.AppFont,
            color: textColorHint ?? Colors.grey,
            fontSize: fontSize ?? 14,
            fontWeight: fontWeight ?? FontWeight.w400,
          ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding:
            EdgeInsets.symmetric(vertical: 0, horizontal: 5),

      ),
    );
  }
}
