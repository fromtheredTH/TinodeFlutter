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
import 'package:tinodeflutter/Screen/Login/CreateAccountScreen.dart';
import 'package:tinodeflutter/Screen/Login/login_controller.dart';
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

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({Key? key}) : super(key: key);

  @override
  _EmailLoginScreen createState() => _EmailLoginScreen();
}

class _EmailLoginScreen extends State<EmailLoginScreen> {
    LoginController controller = Get.put(LoginController());
  RxBool isVisiblePassword = true.obs;
  bool isLoginIng = false;

  Future<void> onClickLogin() async {
    try {
      final data = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: controller.emailController.text,
        password: controller.passwordController.text,
      );

      String token =
          "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}";

      String device_id = "";
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        device_id = androidInfo.id;
        const _androidIdPlugin = AndroidId();
        device_id = await _androidIdPlugin.getId() ?? '';
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        device_id = iosInfo.identifierForVendor ?? '';
      }

      //var response = await apiP.userInfo(token);
     // UserModel user = UserModel.fromJson(response.data["result"]["user"]);

      if(isLoading) {
        Get.back();
        isLoading = false;
      }
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('authProvider', "email");
      prefs.setString('id', controller.emailController.text);
      prefs.setString('pwd', controller.passwordController.text);
      //Constants.getUserInfo(true, context, apiP);

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

  Future<void> socialLogin(UserSocialInfo userInfo) async {
    try {
      String token =
          "${await FirebaseAuth.instance.currentUser?.getIdToken()}";
     // var response = await apiP.userInfo(token);
      if(isLoading) {
        Get.back();
        isLoading = false;
      }
     // UserModel user = UserModel.fromJson(response.data["result"]["user"]);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('authProvider', userInfo.authProvider.name);
      prefs.setString('accessToken', userInfo.accessToken ?? "");
      prefs.setString('idToken', userInfo.refreshToken ?? "");
    //  Constants.getUserInfo(true, context, apiP);
      Get.offAll(MessageRoomListScreen(tinode: tinode_global));
    } catch (e) {
      print(e);
      if(isLoading) {
        Get.back();
        isLoading = false;
      }
      isLoginIng = false;
      Get.to(CreateAccount(
        socialInfo: userInfo,
      ));
    }
  }


 Future<bool> onKeyboardHide() async {
    if (keyboardIsVisible(context)) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
    return false;
  }

   Widget googleLoginWidget()
  {
    return   GestureDetector(
                onTap: () async {
                  if (isLoginIng) {
                    return;
                  }
                  isLoginIng = true;
                  if(!isLoading)
                  {Utils.showDialogWidget(context);
                  isLoading=true;}

                  SocialService socialService = GetIt.I.get<SocialService>();
                  UserSocialInfo? socialInfo =
                      await socialService.getProfile(model.AuthProvider.google);
                  if(isLoading) {
                    Get.back();
                    isLoading = false;
                  }
                  if (socialInfo != null) {
                    socialLogin(socialInfo);
                  } else {
                    isLoginIng = false;
                  }
                },
                
                child: Container(
                  margin: EdgeInsets.symmetric(vertical:  5),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(5),
                     boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 10),
                      
                      SvgPicture.asset(
                        ImageConstants.googleLogo,
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: AppText(
                          text: "구글 계정으로 로그인",
                          color: ColorConstants.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
  }
  Widget appleLoginWidget()
  {
    return GestureDetector(
                  onTap: () async {
                    if (isLoginIng) {
                      return;
                    }
                    if(!isLoading)
                    {Utils.showDialogWidget(context); isLoading=true;}
                    isLoginIng = true;
                    SocialService socialService = GetIt.I.get<SocialService>();
                    UserSocialInfo? socialInfo = await socialService
                        .getProfile(model.AuthProvider.apple);
                    if(isLoading) {
                      Get.back();
                      isLoading = false;
                    }   
                    if (socialInfo != null) {
                      socialLogin(socialInfo);
                    } else {
                      isLoginIng = false;
                    }
                  },
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(vertical:  5),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Color(0xFF000000),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 10),
                        SvgPicture.asset(
                          ImageConstants.appleLogo,
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: AppText(
                            text: "signin_apple".tr(),
                            color: ColorConstants.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
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
                    text: "이메일 로그인",
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
                        controller: controller.emailController,
                        onChanged: (text) {
                          controller.emailValidationText.value = "";
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
                          hintText: "email_address".tr(),
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
                          controller.emailValidationText.value,
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
                            controller: controller.passwordController,
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
                      height: 10,
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
                        if (!EmailValidator.validate(
                            controller.emailController.text, true)) {
                          // Use EmailValidator.validate() to validate email
                          controller.emailValidationText.value =
                              "email_guide_incorrect".tr();
                          isLoginIng = false;
                          if(isLoading) {
                              Get.back();
                              isLoading = false;
                            }
                        } else {
                          if (controller.emailController.text.isEmpty) {
                            showToast("please_input_email".tr());
                            isLoginIng = false;
                            if(isLoading) {
                              Get.back();
                              isLoading = false;
                            }
                            return;
                          } else if (controller
                              .passwordController.text.isEmpty) {
                            showToast("please_input_password".tr());
                            isLoginIng = false;
                            if(isLoading) {
                                Get.back();
                                isLoading = false;
                              }
                            return;
                          }
                          // var emailResponse = await DioClient.checkEmail(
                          //     controller.emailController.text);

                          // if (emailResponse.data["result"] is bool &&
                          //     !emailResponse.data["result"]) {
                          //   controller.emailValidationText.value =
                          //       "email_is_empty".tr();
                          //  if(isLoading) {
                          //     Get.back();
                          //     isLoading = false;
                          //   }
                          //   isLoginIng = false;
                          //   return;
                          // }
                          controller.emailValidationText.value = "";
                          if(isLoading) {
                              Get.back();
                              isLoading = false;
                            }
                          onClickLogin();
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
                    SizedBox(height: 10,),
                    Align(
                      alignment: Alignment.center,
                      child: AppText(
                        text: "소셜 로그인",
                        textAlign: TextAlign.center,
                        fontSize: 13,
                        color: ColorConstants.halfBlack,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
          
             
             googleLoginWidget(),
            if (!Platform.isAndroid) appleLoginWidget(),
               
             
             
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }
}
