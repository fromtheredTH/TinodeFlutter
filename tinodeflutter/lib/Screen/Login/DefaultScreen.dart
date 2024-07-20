import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinodeflutter/Constants/utils.dart';
import 'package:tinodeflutter/Screen/Login/CreateAccountPhoneNumber.dart';
import 'package:tinodeflutter/Screen/Login/CreateAccountScreen.dart';
import 'package:tinodeflutter/Screen/Login/LoginScreen.dart';
import 'package:tinodeflutter/Screen/Login/SignupTypeScreen.dart';
import 'package:tinodeflutter/Screen/Login/login.dart';
import 'package:tinodeflutter/app_text.dart';


import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/page/base/base_state.dart';
import 'package:tinodeflutter/page/base/page_layout.dart';
import 'package:tinodeflutter/services/social_service.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/Constants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../global/global.dart';
import '../../../helpers/common_util.dart';

class DefaultScreen extends StatefulWidget {
  const DefaultScreen({Key? key}) : super(key: key);

  @override
  _DefaultScreen createState() => _DefaultScreen();
}

class _DefaultScreen extends BaseState<DefaultScreen> {


  Future<bool> onKeyboardHide() async {
    if (keyboardIsVisible(context)) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      isAvoidResize: false,
      onTap: onKeyboardHide,
      isLoading: isLoading,
      safeAreaColor: Colors.white,
      child: Scaffold(
        backgroundColor: ColorConstants.white,
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // SvgPicture.asset(ImageConstants.appLogo, width:  Get.width*0.9,),
                    // Image.asset(ImageConstants.splashLogo,width: Get.width*0.5, fit: BoxFit.cover,),

                  //   Stack(children: [
                  //      Expanded(
                  //       child: Center(
                  //         child: Image.asset(
                  //           ImageConstants.homescreen_ads_01,
                  //           width: Get.width ,
                  //           fit: BoxFit.cover,
                  //         ),
                  //       ),
                  // ),
                  //   ],),
                    Center(
                      child: SvgPicture.asset(ImageConstants.appLogo, width:  Get.width*0.8 ,)
                      ),
                    // SizedBox(
                    //   height: 30,
                    // ),
                    // AppText(
                    //   text: "JadeChat에 오신걸 환영합니다!",
                    //   color: ColorConstants.black,
                    //   fontSize: 16,
                    //   fontWeight: FontWeight.w700,
                    //   textAlign: TextAlign.center,
                    // ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    // AppText(
                    //   text:
                    //       "JadeChat 회원가입으로 다양한 혜택을 누려보세요!",
                    //   color: ColorConstants.halfBlack,
                    //   fontSize: 14,
                    //   textAlign: TextAlign.center,
                    // ),
                  ],
                ),
                )
              ),
                
            
              SizedBox(height: 10),
              ElevatedButton(
                      onPressed: () {
                        Get.to(Login());
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: Size(Get.width, 50),
                          backgroundColor: ColorConstants.colorMain,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(
                                color: ColorConstants.colorMain.withOpacity(0.5),
                                width:1.0
                                ),                              
                          )),
                          
                      child: Center(
                        child: AppText(
                          text: "옛날 로그인(ID PW) 페이지",
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      )).paddingSymmetric(vertical: 10)
              ,
              ElevatedButton(
                      onPressed: () {
                        Get.to(LoginScreen());
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: Size(Get.width, 50),
                          backgroundColor: ColorConstants.colorMain,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(
                                color: ColorConstants.colorMain.withOpacity(0.5),
                                width:1.0
                                ),                              
                          )),
                          
                      child: Center(
                        child: AppText(
                          text: "로그인",
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      )).paddingSymmetric(vertical: 10)
              ,
              ElevatedButton(
                      onPressed: () {
                        Get.to(SignupTypeScreen());
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: Size(Get.width, 50),
                          backgroundColor: ColorConstants.colorMain,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(
                                color: ColorConstants.colorMain.withOpacity(0.5),
                                width:1.0
                                ),                              
                          )),
                          
                      child: Center(
                        child: AppText(
                          text: "회원가입",
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      )).paddingSymmetric(vertical: 10)
              ,
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }
}
