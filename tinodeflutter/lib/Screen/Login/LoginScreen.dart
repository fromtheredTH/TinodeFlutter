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
import 'package:tinodeflutter/Screen/BottomNavBarScreen.dart';
import 'package:tinodeflutter/Screen/Login/CreateAccountScreen.dart';
import 'package:tinodeflutter/Screen/Login/EmailLoginScreen.dart';
import 'package:tinodeflutter/Screen/messageRoomListScreen.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/model/UserAuthModel.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/page/base/page_layout.dart';
import 'package:tinodeflutter/services/social_service.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/Constants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../global/global.dart';
import '../../../helpers/common_util.dart';
import 'package:tinodeflutter/model/UserAuthModel.dart' as model;
import 'forget_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  
  TextEditingController phoneNumberController=TextEditingController();
  TextEditingController passwordController=TextEditingController();
  RxString phoneNumberValidationText="".obs;
  RxBool isVisiblePassword = true.obs;
  bool isLoginIng = false;

  late String firebaseToken;
  late String phoneNumberEmail;

  Future<void> onClickPhoneNumberLogin() async {
    try {
      phoneNumberEmail = '${phoneNumberController.text}@phoneNumber.com';

      final data = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: phoneNumberEmail,
        password: passwordController.text,
      );

      firebaseToken = "${await FirebaseAuth.instance.currentUser?.getIdToken()}";

      // device id get 코드
      // String device_id = "";
      // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      // if (Platform.isAndroid) {
      //   AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      //   device_id = androidInfo.id;
      //   const _androidIdPlugin = AndroidId();
      //   device_id = await _androidIdPlugin.getId() ?? '';
      // } else if (Platform.isIOS) {
      //   IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      //   device_id = iosInfo.identifierForVendor ?? '';
      // }
       var response = await tinode_global.firebaseLogin(firebaseToken);
      print('User Id: ' + response.toString());

      if(isLoading) {
        Get.back();
        isLoading = false;
      }
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('authProvider', "email");
      prefs.setString('token', token);
      prefs.setString('url_encoded_token', url_encoded_token);
      prefs.setInt('login_type', 1); // 0 : id , pw  // 1: firebase
      //Constants.getUserInfo(true, context, apiP);

      Get.offAll(BottomNavBarScreen());

    } on FirebaseAuthException catch (e) {
      print(e.code);
      if(isLoading) {
        Get.back();
        isLoading = false;
      }
      isLoginIng = false;
      showToast('${e.code}:${e.message ?? ''}');
    }
  }



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
                  SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                          onTap: (){
                            Get.back();
                          },
                          child: Icon(Icons.arrow_back_ios, color:Colors.black)),
                      AppText(
                        text: "로그인",
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),

                    ],
                  ),
                  SizedBox(height: 15,),
                  Center(child: AppText(
                    text: "휴대폰 번호 로그인",
                    fontSize: 21,
                    color: ColorConstants.black,
                    fontWeight: FontWeight.w700,
                  )
                  ,),
                  SizedBox(height: 30,),
                  
                
              // Expanded(
              //     child: Container(
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     children: [
              //       Center(child: SvgPicture.asset(ImageConstants.appLogo)),
              //       SizedBox(
              //         height: 30,
              //       ),
              //       AppText(
              //         text: "JadeChat에 오신걸 환영합니다!",
              //         color: ColorConstants.white,
              //         fontSize: 16,
              //         fontWeight: FontWeight.w700,
              //         textAlign: TextAlign.center,
              //       ),
              //       SizedBox(
              //         height: 10,
              //       ),
              //       AppText(
              //         text:
              //             "JadeChat 회원가입으로 다양한 혜택을 누려보세요!",
              //         color: ColorConstants.halfWhite,
              //         fontSize: 14,
              //         textAlign: TextAlign.center,
              //       ),
              //     ],
              //   ),
              // )),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            color: ColorConstants.black.withOpacity(0.5)),
                      ),
                      child: TextField(
                        style: TextStyle(color: Colors.black.withOpacity(0.7)),
                        cursorColor: Colors.black.withOpacity(0.7),
                        controller: phoneNumberController,
                        onChanged: (text) {
                          phoneNumberValidationText.value = "";
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.1),
                          prefixIcon: Container(
                            margin: EdgeInsets.only(right: 15),
                            width: 50,
                            height: 50,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              color: ColorConstants.black.withOpacity(0.7),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5.0),
                                  bottomLeft: Radius.circular(5.0)),
                            ),
                            child: SvgPicture.asset(
                              ImageConstants.user,
                              width: 25,
                              height: 25,
                            ),
                          ),
                          prefixIconColor: ColorConstants.black,
                          prefixIconConstraints:
                              BoxConstraints(minWidth: 40, minHeight: 40),
                          hintText: "휴대폰 번호를 입력해 주세요.",
                          hintStyle: TextStyle(
                            fontSize: 14,
                            fontFamily: FontConstants.AppFont,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    Obx(() => Text(
                          phoneNumberValidationText.value,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Color(0xFFEB5757),
                          ),
                        )),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color: ColorConstants.black.withOpacity(0.5)),
                        ),
                        child: Obx(
                          () => TextField(
                            controller: passwordController,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                            ),
                            obscureText: isVisiblePassword.value,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.1),
                              prefixIcon: Container(
                                margin: EdgeInsets.only(right: 15),
                                width: 50,
                                height: 50,
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                decoration: BoxDecoration(
                                  color: ColorConstants.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(5.0),
                                      bottomLeft: Radius.circular(5.0)),
                                ),
                                child: SvgPicture.asset(
                                  ImageConstants.lock,
                                  width: 25,
                                  height: 25,
                                ),
                              ),
                              prefixIconColor: ColorConstants.black,
                              prefixIconConstraints: const BoxConstraints(
                                  minWidth: 40, minHeight: 40),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  isVisiblePassword.value =
                                      !isVisiblePassword.value;
                                },
                                child: Image.asset(!isVisiblePassword.value
                                        ? ImageConstants.openEyeButton
                                        : ImageConstants.eyeButton)
                                    .paddingOnly(right: 10),
                              ),
                              suffixIconConstraints:
                                  BoxConstraints(minWidth: 20, minHeight: 20),
                              hintText: "pw_hint".tr(),
                              hintStyle: TextStyle(
                                fontSize: 14,
                                fontFamily: FontConstants.AppFont,
                                fontWeight: FontWeight.w400,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     Get.to(ForgetScreen());
                    //   },
                    //   child: Align(
                    //     alignment: Alignment.centerRight,
                    //     child: AppText(
                    //       text: "are_you_pwd_forget".tr(),
                    //       textAlign: TextAlign.end,
                    //       fontSize: 12,
                    //     ),
                    //   ),
                    // ),
                    SizedBox(
                      height: 20,
                    ),
                    
                    Align(
                      alignment: Alignment.center,
                      child:
                      GestureDetector(
                        onTap: () => {Get.off(EmailLoginScreen())},
                        child: AppText(
                        text: "기타 로그인 옵션",
                        textAlign: TextAlign.center,
                        fontSize: 14,
                        color: ColorConstants.blue1,
                      ),

                      ),
                     
                    ),

                    SizedBox(height: 30,),
                    

                     Align(
                      alignment: Alignment.center,
                        child: AppText(
                        text: "위의 휴대폰 번호는 로그인 인증용으로만 사용됩니다.",
                        textAlign: TextAlign.center,
                        fontSize: 11,
                        color: ColorConstants.halfBlack,
                      ),
                      ),
                     

                    GestureDetector(
                      onTap: () async {
                        if (isLoginIng) {
                          print("로그인 폴스");
                          return;
                        }
                        print("로그인 트루");
                        isLoginIng = true;
                         if(!isLoading)
                          {Utils.showDialogWidget(context);
                          isLoading=true;}
                        if (!GetUtils.isPhoneNumber(
                            phoneNumberController.text)) {
                          // Use EmailValidator.validate() to validate email
                          phoneNumberValidationText.value =
                              "올바른 휴대폰 번호 형식을 입력해 주세요";
                          isLoginIng = false;
                          if(isLoading) {
                              Get.back();
                              isLoading = false;
                            }
                        } else {
                          if (phoneNumberController.text.isEmpty) {
                            onKeyboardHide();
                            showToast("휴대폰 번호를 입력해주세요");
                            isLoginIng = false;
                            if(isLoading) {
                              Get.back();
                              isLoading = false;
                            }
                            return;
                          } else if (passwordController.text.isEmpty) {
                            onKeyboardHide();
                            showToast("please_input_password".tr());
                            isLoginIng = false;
                            if(isLoading) {
                                Get.back();
                                isLoading = false;
                              }
                            return;
                          }
                          // var emailResponse = await DioClient.checkEmail(
                          //     controller.phoneNumberController.text);

                          // if (emailResponse.data["result"] is bool &&
                          //     !emailResponse.data["result"]) {
                          //   controller.phoneNumberValidationText.value =
                          //       "email_is_empty".tr();
                          //  if(isLoading) {
                          //     Get.back();
                          //     isLoading = false;
                          //   }
                          //   isLoginIng = false;
                          //   return;
                          // }
                          phoneNumberValidationText.value = "";
                          if(isLoading) {
                              Get.back();
                              isLoading = false;
                            }
                          onClickPhoneNumberLogin();
                        }
                      },
                      child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: ColorConstants.colorMain,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: AppText(
                              text: "login".tr(),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          )),
                    ),
                  ],
                ),                   
          
           
             
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }
}
