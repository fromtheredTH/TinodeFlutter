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
import 'package:tinodeflutter/Screen/Login/CreateAccountPhoneNumber.dart';
import 'package:tinodeflutter/Screen/Login/CreateAccountScreen.dart';
import 'package:tinodeflutter/Screen/messageRoomListScreen.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:tinodeflutter/model/UserAuthModel.dart' ;
import 'package:tinodeflutter/model/UserAuthModel.dart' as model;

import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/page/base/page_layout.dart';
import 'package:tinodeflutter/services/social_service.dart';
import 'package:tinodeflutter/tinode/src/models/account-params.dart';
import 'package:tinodeflutter/tinode/src/models/credential.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/Constants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../helpers/common_util.dart';

class SignupTypeScreen extends StatefulWidget {
  const SignupTypeScreen({Key? key}) : super(key: key);

  @override
  _SignupTypeScreen createState() => _SignupTypeScreen();
}

class _SignupTypeScreen extends State<SignupTypeScreen> {
  // LoginController controller = Get.put(LoginController());
  RxBool isVisiblePassword = true.obs;
  bool isOnlySocial = true;

  bool isLoginIng = false;
  late String firebaseToken;

  Future<void> socialLogin(UserSocialInfo userInfo) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
     firebaseToken = "${await FirebaseAuth.instance.currentUser?.getIdToken()}";
      
      prefs.setString('authProvider', userInfo.authProvider.name);
      prefs.setString('accessToken', userInfo.accessToken ?? "");
      prefs.setString('idToken', userInfo.refreshToken ?? "");

      if(isLoading) {
        Get.back();
        isLoading = false;
      }
      String userName = userInfo.uid ?? "";
      Credential credential = Credential();
     
      var response = await tinode_global.firebaseLogin(firebaseToken);
      print('User Id: ' + response.toString());
        
     

      //await createAccount(userName);

        Constants.initSetting();
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

  Future<void> createAccount(String userName) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

     try{
        AccountParams accountParams = AccountParams(cred: [] , public:{'fn':userName} );
      
        var result = await tinode_global.createAccountFirebase(userName, "",  accountParams, firebaseToken , login: true);
        
        token = result.params['token'];
        url_encoded_token = Uri.encodeComponent(result.params['token']);
        prefs.setString('token', token);
        prefs.setString('url_encoded_token', url_encoded_token);

        tinode_global.setDeviceToken(gPushKey); //fcm push token 던지기

      }
      catch(err)
      {
       // duplicate
         print("firebase signup err");
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
                  margin: EdgeInsets.symmetric(vertical: isOnlySocial ? 10 : 5),
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
                          text: "구글 계정으로 회원가입",
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
                        EdgeInsets.symmetric(vertical: isOnlySocial ? 10 : 5),
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
                            text: "애플 계정으로 회원가입",
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
              Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // SvgPicture.asset(ImageConstants.appLogo, width:  Get.width*0.9,),
                    Center(
                      child: SvgPicture.asset(ImageConstants.appLogo, width:  Get.width*0.8 ,)
                      ),
                    SizedBox(
                      height: 30,
                    ),
                    AppText(
                      text: "JadeChat에 오신걸 환영합니다!",
                      color: ColorConstants.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    AppText(
                      text:
                          "JadeChat 회원가입으로 다양한 혜택을 누려보세요!",
                      color: ColorConstants.halfBlack,
                      fontSize: 14,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                )
              ),
                
            
              googleLoginWidget(),
              if (!Platform.isAndroid)
               appleLoginWidget(),
              SizedBox(height: 10),
              ElevatedButton(
                      onPressed: () {
                        Get.to(CreateAccountPhoneNumber());
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
                          text: "휴대폰 번호 회원가입",
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      )).paddingSymmetric(vertical: 10)
              ,
              ElevatedButton(
                      onPressed: () {
                        Get.to(CreateAccount());
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
                          text: "이메일 회원가입",
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
