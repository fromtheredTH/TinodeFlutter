


import 'dart:convert';
import 'dart:io';


import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinodeflutter/Constants/Constants.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/utils.dart';

import '../../components/MyAssetPicker.dart';


class SettingSecurityScreen extends StatefulWidget {
  SettingSecurityScreen({super.key, });

  @override
  State<SettingSecurityScreen> createState() => _SettingSecurityScreen();
}

class _SettingSecurityScreen extends State<SettingSecurityScreen> {

  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if(Constants.user.idVerified){
      phoneController.text = Constants.user.verifiedInfo.mobileNum;
    }
    passwordEmailController.text = Constants.user.email;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: ColorConstants.colorBg1,
        resizeToAvoidBottomInset: true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Get.height*0.07),
            Padding(
              padding:EdgeInsets.only(left: 15, right: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                          onTap: (){
                            Get.back();
                          },
                          child: Icon(Icons.arrow_back_ios, color:Colors.white)),

                      AppText(
                        text: "sicurity".tr(),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )
                    ],
                  ),

                ],
              ),
            ),
            SizedBox(height: 30),

           Container(
             margin: EdgeInsets.only(left: 20),
             child:  AppText(
               text: "please_sicurity".tr(),
               fontWeight: FontWeight.w700,
             ),
           ),

            SizedBox(height: 10,),

            Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                border: Border.all(
                  color: ColorConstants.halfWhite,
                  width: 0.5
                ),
                borderRadius: BorderRadius.all(Radius.circular(4))
              ),
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 13,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w400,
                        ),
                        readOnly: Constants.user.idVerified,
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          filled: true,
                            fillColor: ColorConstants.colorBg1,
                            hintText: "please_phone_sicurity".tr(),
                            hintStyle: TextStyle(
                              color: Color(0xFFFFFFFF).withOpacity(0.5),
                              fontWeight: FontWeight.w400,
                              fontFamily: FontConstants.AppFont,
                              fontSize: 13,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              gapPadding: 5,
                              borderSide: BorderSide(
                                  color: Colors.transparent,
                                  width: 0
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              gapPadding: 5,
                              borderSide: BorderSide(
                                  color: Colors.transparent,
                                  width: 0
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 0)),
                      ),
                  ),

                  SizedBox(width: 10,),

                  GestureDetector(
                    onTap: () async {
                      if(phoneController.text.isEmpty){
                        Utils.showToast("empty_phone".tr());
                        return;
                      }
                      if(!Constants.user.idVerified){
                        if(GetUtils.isPhoneNumber(phoneController.text)) {
                          // var response = await DioClient.niceCertify();
                          Get.to(SettingNiceScreen(
                            // encData: response.data["result"]["enc_data"],
                            // integrityValue: response.data["result"]["integrity_value"],
                            // tokenVersionId: response.data["result"]["token_version_id"],
                            //   request_no: response.data["result"]["request_no"]
                          ));
                        }else{
                          Utils.showToast("phone_incorrect".tr());
                          return;
                        }
                      }
                      // Utils.showToast("제작중인 기능입니다");
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Constants.user.idVerified ? ColorConstants.textGry : ColorConstants.colorMain
                      ),
                      child: AppText(
                        text: Constants.user.idVerified ? "sicurity_complete".tr() :"please_sicurity".tr(),
                        fontSize: 12,
                      ),
                    )
                  )
                ],
              ),
            ),

            SizedBox(height: 30,),

            Container(
              margin: EdgeInsets.only(left: 20),
              child:  AppText(
                text: "change_password".tr(),
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 10,),

            Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: ColorConstants.halfWhite,
                      width: 0.5
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(4))
              ),
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                        color: ColorConstants.halfWhite,
                        fontSize: 13,
                        fontFamily: FontConstants.AppFont,
                        fontWeight: FontWeight.w400,
                      ),
                      readOnly: true,
                      controller: passwordEmailController,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: ColorConstants.colorBg1,
                          hintText: "",
                          hintStyle: TextStyle(
                            color: Color(0xFFFFFFFF).withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                            fontFamily: FontConstants.AppFont,
                            fontSize: 13,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            gapPadding: 5,
                            borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 0
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            gapPadding: 5,
                            borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 0
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 0)),
                    ),
                  ),

                  SizedBox(width: 10,),

                  GestureDetector(
                      onTap: (){
                        FirebaseAuth.instance.sendPasswordResetEmail(email: Constants.user.email).then((error) {
                          Utils.showToast("toast_edit_password_email".tr());
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Constants.user.idVerified ? ColorConstants.textGry : ColorConstants.colorMain
                        ),
                        child: AppText(
                          text: "edit_password_email".tr(),
                          fontSize: 12,
                        ),
                      )
                  )
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.only(left: 20, top: 5),
              child:  AppText(
                text: "toast_edit_password_email_description".tr(),
                fontSize: 13,
                color: ColorConstants.halfWhite,
              ),
            ),

          ],
        )
    );

  }
}