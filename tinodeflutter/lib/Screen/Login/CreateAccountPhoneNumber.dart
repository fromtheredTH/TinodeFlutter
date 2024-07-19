


import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:tinodeflutter/Constants/utils.dart';
import 'package:tinodeflutter/Screen/messageRoomListScreen.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/app_text_field.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:tinodeflutter/model/UserAuthModel.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/page/base/page_layout.dart';
import 'package:tinodeflutter/tinode/src/models/account-params.dart';
import 'package:tinodeflutter/tinode/src/models/credential.dart';
import '../../../../Constants/ColorConstants.dart';
import '../../../../Constants/Constants.dart';
import '../../../../Constants/FontConstants.dart';
import '../../../../Constants/ImageConstants.dart';
import '../../../../global/DioClient.dart';
import 'package:shared_preferences/shared_preferences.dart';



class CreateAccountPhoneNumber extends StatefulWidget {
   CreateAccountPhoneNumber({super.key, this.socialInfo});
   UserSocialInfo? socialInfo;

  @override
  State<CreateAccountPhoneNumber> createState() => _CreateAccountPhoneNumberState();
}


class _CreateAccountPhoneNumberState extends State<CreateAccountPhoneNumber> {

  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController nicknameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();

  RxBool isTapEmailOkBtn = false.obs;
  RxBool isPhoneNumberEmpty = true.obs;
  RxBool isPhoneNumberCorrect = true.obs;
  RxBool isPhoneNumberNotDuplicate = true.obs;

  RxBool isTapNicknameOkBtn = false.obs;
  RxBool isNicknameEmpty = true.obs;
  RxBool isNicknameLengthCorrect = true.obs;
  RxBool isNicknameCorrect = true.obs;
  RxBool isNicknameNotDuplicate = true.obs;

  RxBool isTapNameOkBtn = false.obs;
  RxBool isNameEmpty = true.obs;
  RxBool isNameCorrect = true.obs;

  RxBool isTapPasswordOkBtn = false.obs;
  RxBool isPasswordEmpty = true.obs;
  RxBool isPasswordCorrect = true.obs;

  RxBool isTapPasswordConfirmOkBtn = false.obs;
  RxBool isPasswordConfirmCorrect = true.obs;

  RxBool isEveryOneAgrees = false.obs;
  RxBool isAgreeTermOfServices = false.obs;
  RxBool isAgreeToPersonalInfo = false.obs;
  RxBool isAgreeToMarketingPromotion = false.obs;

  void setAgree() {
    if(!isAgreeTermOfServices.value || !isAgreeToPersonalInfo.value || !isAgreeToMarketingPromotion.value) {
      isEveryOneAgrees.value = false;
    }else if(isAgreeTermOfServices.value && isAgreeToPersonalInfo.value && isAgreeToMarketingPromotion.value) {
      isEveryOneAgrees.value = true;
    }
  }

  void setAllAgree() {
    isAgreeTermOfServices.value = isEveryOneAgrees.value;
    isAgreeToPersonalInfo.value = isEveryOneAgrees.value;
    isAgreeToMarketingPromotion.value = isEveryOneAgrees.value;
  }

  @override
  void initState() {
    nameController.text = widget.socialInfo?.name ?? "";
    super.initState();
  }
  String firebaseToken = "";
  late String phoneNumberEmail;

  void signUpProcess() async
  {
    try{
    await signUpWithPhoneNumber();
    await FirebaseAuth.instance.signInWithEmailAndPassword(
           email: phoneNumberEmail,
           password: passwordController.text,
      );
     var response= await FirebaseAuth.instance.currentUser?.getIdToken();
    if(response!=null) firebaseToken = response;

    // var signupResponse = await DioClient.signUp(nicknameController.text, nameController.text);
    // UserModel user = UserModel.fromJson(signupResponse.data["result"]["user"]);
    _submitAccountForm();

    }
    on FirebaseAuthException catch (e) {
      Utils.showToast(e.message ?? "");
      print(e.code);
      }    
  }

   void _submitAccountForm() async{
      
      if(gPushKey=="") showToast('fcm token 없음');
      final prefs = await SharedPreferences.getInstance();
      String base64EncodedFirebaseToken = await encodeStringToBase64(firebaseToken);
      AccountParams accountParams = AccountParams(cred: [] , public:{'fn':nameController.text} );
      try{
       var result = await tinode_global.createAccountFirebase(nameController.text, passwordController.text,  accountParams, firebaseToken , login: true);
       token = result.params['token'];
       url_encoded_token = Uri.encodeComponent(result.params['token']);
        prefs.setString('token', token);
        prefs.setString('url_encoded_token', url_encoded_token);

       tinode_global.setDeviceToken(gPushKey); //fcm push token 던지기
       Get.offAll(MessageRoomListScreen(
      ));
      }
      catch(err)
      {
        showToast('회원가입 실패 $err');
        Get.back(); //loading off
        return;
      }

      Get.back(); // loading off
      Utils.showToast("complete_sign_up".tr());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입이 완료되었습니다.')),
      );
    
  }

  
  Future<UserCredential?> signUpWithPhoneNumber() async {
    try {
      // 전화번호를 이메일 형식으로 변환
      phoneNumberEmail = '${phoneNumberController.text}@phoneNumber.com';

      // Firebase에 회원가입
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: phoneNumberEmail,
        password: passwordController.text,
      );


      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('회원가입 실패: ${e.message}');
      return null;
    }
  }


  

  @override
  Widget build(BuildContext context) {
    return PageLayout(
        child: Scaffold(
          backgroundColor: ColorConstants.white,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Padding(
              padding:EdgeInsets.only(left: 15, right: 15),
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
                        text:  "signup".tr(),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),

                    ],
                  ),

                  Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // SizedBox(height: 25),
                            // AppText(
                            //   text: "JadeChat 회원가입으로 다양한 혜택을 누려보세요!",
                            //   fontSize: 16,
                            // ),
                            //SizedBox(height: Get.height*0.05),
                            SizedBox(height: Get.height*0.01),

                            widget.socialInfo != null ?
                            Container(
                              width: double.maxFinite,
                              child: AppText(
                                text: widget.socialInfo!.email!,
                                fontSize: 14,
                                color: ColorConstants.halfBlack,
                              ),
                            )
                                : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                AppTextField(
                                  textController: phoneNumberController,                                  
                                  onChanged: (value) {
                                    isTapEmailOkBtn.value = false;
                                    isPhoneNumberEmpty.value = value.isEmpty;
                                    isPhoneNumberNotDuplicate.value = true;
                                    if(!GetUtils.isPhoneNumber(value) && value.isNotEmpty) {
                                      isPhoneNumberCorrect.value = false;
                                    }else{
                                      isPhoneNumberCorrect.value = true;

                                      // DioClient.checkEmail(value).then((value) {
                                      //   if(value.data["result"] is bool){
                                      //     isPhoneNumberNotDuplicate.value = false;
                                      //   }else{
                                      //     isPhoneNumberNotDuplicate.value = true;
                                      //   }
                                      // });

                                    }
                                  },
                                  hintText: "휴대폰 번호",
                                  textColor: Colors.black,
                                  textColorHint: ColorConstants.halfBlack,
                                ),

                                SizedBox(height: 5,),

                                Obx(() => AppText(
                                  text:
                                  isPhoneNumberCorrect.value && isPhoneNumberNotDuplicate.value && isPhoneNumberEmpty.value ? "please_input_phone_number".tr() :
                                  isPhoneNumberCorrect.value && isPhoneNumberNotDuplicate.value ? "correct_phone_number".tr() :
                                  !isPhoneNumberCorrect.value ? "phone_number_guide_incorrect".tr()
                                      : "already_phone_number".tr(),
                                  color: isPhoneNumberCorrect.value && isPhoneNumberNotDuplicate.value && isPhoneNumberEmpty.value ? isTapEmailOkBtn.value ? ColorConstants.red : ColorConstants.halfBlack :
                                  isPhoneNumberCorrect.value && isPhoneNumberNotDuplicate.value ? ColorConstants.halfBlack :
                                  !isPhoneNumberCorrect.value ? ColorConstants.red
                                      : ColorConstants.red,
                                  fontSize: 11,
                                  maxLine: 2,
                                ))
                              ],
                            ),

                            SizedBox(height: Get.height*0.01),

                            // Column(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [

                            //     AppTextField(
                            //       textController: nicknameController,
                            //       onChanged: (value) {
                            //         isTapNicknameOkBtn.value = false;
                            //         isNicknameEmpty.value = value.isEmpty;
                            //         isNicknameNotDuplicate.value = true;
                            //         if(value.isNotEmpty && value.length < 4) {
                            //           isNicknameLengthCorrect.value = false;
                            //         }else{
                            //           isNicknameLengthCorrect.value = true;
                            //           if(!GetUtils.hasMatch(value,r'^(?=.*[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ])[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ._]{4,15}$')){
                            //             isNicknameCorrect.value = false;
                            //           }else{
                            //             isNicknameCorrect.value = true;
                            //             // DioClient.checkNickname(value).then((value) {
                            //             //   if(value.data["result"]["success"] is bool){
                            //             //     isNicknameNotDuplicate.value = !value.data["result"]["success"];
                            //             //   }
                            //             // });
                            //           }
                            //         }
                            //       },
                            //       hintText: "nickname".tr(),
                            //       textColor: Colors.black,
                            //       textColorHint: ColorConstants.halfBlack,
                            //     ),

                            //     SizedBox(height: 5,),

                            //     Obx(() => AppText(
                            //       text:
                            //       isNicknameEmpty.value ? "please_input_nickname".tr() :
                            //       !isNicknameLengthCorrect.value ? "nickname_length_incorrect".tr() :
                            //       !isNicknameNotDuplicate.value ? "already_use_nickname".tr() :
                            //       !isNicknameCorrect.value ? "nickname_format_guide".tr() :
                            //       "enable_nickname".tr(),
                            //       color: isNicknameEmpty.value ? ColorConstants.halfBlack :
                            //       !isNicknameLengthCorrect.value ? ColorConstants.red :
                            //       !isNicknameNotDuplicate.value ? ColorConstants.red :
                            //       !isNicknameCorrect.value ? ColorConstants.red :
                            //       ColorConstants.halfBlack,
                            //       fontSize: 11,
                            //       maxLine: 2,
                            //     ))
                            //   ],
                            // ),

                            // SizedBox(height: Get.height*0.01),

                            widget.socialInfo?.uid != null ?
                            Container(
                              width: double.maxFinite,
                              child: AppText(
                                text: widget.socialInfo!.uid ?? "",
                                fontSize: 14,
                                color: ColorConstants.halfBlack,
                              ),
                            )
                                : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                AppTextField(
                                  textController: nameController,
                                  onChanged: (value) {
                                    isTapNameOkBtn.value = false;
                                    isNameEmpty.value = value.isEmpty;
                                    if(value.isNotEmpty && value.length < 2) {
                                      isNameCorrect.value = false;
                                    }else{
                                      isNameCorrect.value = true;
                                    }
                                  },
                                  hintText: "name".tr(),
                                  textColor: Colors.black,
                                  textColorHint: ColorConstants.halfBlack,
                                ),

                                SizedBox(height: 5,),

                                Obx(() => AppText(
                                  text:
                                  !isNameCorrect.value || isNameEmpty.value ? "name_length_incorrect".tr() :
                                  "enable_name".tr(),
                                  color: isNameEmpty.value && isTapNameOkBtn.value ? ColorConstants.red :
                                  !isNameCorrect.value ? ColorConstants.red
                                      : ColorConstants.halfBlack,

                                  fontSize: 11,
                                  maxLine: 2,
                                ))
                              ],
                            ),

                            SizedBox(height: Get.height*0.01),

                            if(widget.socialInfo == null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  AppTextField(
                                    textController: passwordController,
                                    obscureText: true,
                                    onChanged: (value) {
                                      isTapPasswordOkBtn.value = false;
                                      isPasswordEmpty.value = value.isEmpty;
                                      if(!GetUtils.hasMatch(value,r'^(?=.*[a-z])(?=.*[0-9!@#\$%^&*])[a-zA-Z0-9!@#\$%^&*]{6,20}$')) {
                                        isPasswordCorrect.value = false;
                                      }else{
                                        isPasswordCorrect.value = true;
                                      }
                                    },
                                    hintText: "password".tr(),
                                    textColor: Colors.black,
                                    textColorHint: ColorConstants.halfBlack,
                                  ),

                                  SizedBox(height: 5,),

                                  Obx(() => AppText(
                                    text:
                                    "password_format_guide".tr(),
                                    color: isPasswordCorrect.value && isPasswordEmpty.value && isTapPasswordOkBtn.value ? ColorConstants.red :
                                    !isPasswordCorrect.value && !isPasswordEmpty.value ? ColorConstants.red : ColorConstants.halfBlack,
                                    fontSize: 11,
                                    maxLine: 2,
                                  ))
                                ],
                              ),

                            SizedBox(height: Get.height*0.01),

                            if(widget.socialInfo == null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  AppTextField(
                                    textController: passwordConfirmController,
                                    obscureText: true,
                                    onChanged: (value) {
                                      isTapPasswordConfirmOkBtn.value = false;
                                      isPasswordConfirmCorrect.value = true;
                                    },
                                    hintText: "password_confirm".tr(),
                                    textColor: Colors.black,
                                    textColorHint: ColorConstants.halfBlack,
                                  ),

                                  SizedBox(height: 5,),

                                  Obx(() => AppText(
                                    text:
                                    isTapPasswordConfirmOkBtn.value && !isPasswordConfirmCorrect.value ? "check_password".tr() : "",
                                    color: ColorConstants.red,
                                    fontSize: 11,
                                    maxLine: 2,
                                  ))
                                ],
                              ),

                            Container(
                              margin: EdgeInsets.only(top: 15),
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: ColorConstants.black10Percent
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Container(
                                    height: 35,
                                    width: double.maxFinite,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Obx(() => SizedBox(
                                          width:30,
                                          child: Checkbox(
                                            activeColor: ColorConstants.colorMain,
                                            checkColor: ColorConstants.white,
                                            value: isEveryOneAgrees.value,
                                            onChanged: (bool? value) {
                                              isEveryOneAgrees.value = value!;
                                              setAllAgree();
                                            },
                                          ),
                                        )),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: AppText(
                                            text: "all_agree".tr(),
                                            color: ColorConstants.halfBlack,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    height: 35,
                                    width: double.maxFinite,

                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Obx(() => SizedBox(
                                          width:30,
                                          child: Checkbox(
                                            activeColor: ColorConstants.colorMain,
                                            checkColor: ColorConstants.white,
                                            value: isAgreeTermOfServices.value,
                                            onChanged: (bool? value) {
                                              isAgreeTermOfServices.value = value!;
                                              setAgree();
                                            },
                                          ),
                                        )),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: AppText(
                                            text: "service_agree".tr(),
                                            color: ColorConstants.halfBlack,
                                            fontSize: 13,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            if(Constants.languageCode == "ko") {
                                              Utils.urlLaunch("https://jade-chat.com/terms");
                                            }else{
                                              Utils.urlLaunch("https://jade-chat.com/terms");
                                            }
                                          },
                                          child: AppText(
                                            text: "see".tr(),
                                            color: ColorConstants.black,
                                            fontSize: 12,
                                            textDecoration: TextDecoration.underline,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),

                                  Container(
                                    height: 35,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Obx(() => SizedBox(
                                          width:30,
                                          child: Checkbox(
                                            activeColor: ColorConstants.colorMain,
                                            checkColor: ColorConstants.white,
                                            value: isAgreeToPersonalInfo.value,
                                            onChanged: (bool? value) {
                                              isAgreeToPersonalInfo.value = value!;
                                              setAgree();
                                            },
                                          ),
                                        )),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: AppText(
                                            text: "personal_agree".tr(),
                                            color: ColorConstants.halfBlack,
                                            fontSize: 13,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            if(Constants.languageCode == "ko") {
                                              Utils.urlLaunch("https://jade-chat.com/terms");
                                            }else{
                                              Utils.urlLaunch("https://jade-chat.com/terms");
                                            }

                                          },
                                          child: AppText(
                                            text: "see".tr(),
                                            color: ColorConstants.black,
                                            fontSize: 12,
                                            textDecoration: TextDecoration.underline,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),

                                  Container(
                                    height: 35,
                                    width: double.maxFinite,

                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Obx(() => SizedBox(
                                          width:30,
                                          child: Checkbox(
                                            activeColor: ColorConstants.colorMain,
                                            checkColor: ColorConstants.white,
                                            value: isAgreeToMarketingPromotion.value,
                                            onChanged: (bool? value) {
                                              isAgreeToMarketingPromotion.value = value!;
                                              setAgree();
                                            },
                                          ),
                                        )),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: AppText(
                                            text: "marketing_agree".tr(),
                                            color: ColorConstants.halfBlack,
                                            fontSize: 13,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            if(Constants.languageCode == "ko") {
                                              Utils.urlLaunch(
                                                  "https://jade-chat.com/terms-marketing");
                                            }else{
                                              Utils.urlLaunch(
                                                  "https://jade-chat.com/terms-marketing");
                                            }
                                          },
                                          child: AppText(
                                            text: "see".tr(),
                                            color: ColorConstants.black,
                                            fontSize: 12,
                                            textDecoration: TextDecoration.underline,
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )

                          ],
                        ),
                      )
                  ),

                  GestureDetector(
                    onTap: () async {
                      Utils.showDialogWidget(context);
                      if(!isAgreeTermOfServices.value || !isAgreeToPersonalInfo.value) {
                        Get.back();
                        return;
                      }

                      isTapEmailOkBtn.value = true;
                      isTapNameOkBtn.value = true;
                      isTapPasswordOkBtn.value = true;
                      isTapPasswordConfirmOkBtn.value = true;


                      if(widget.socialInfo != null){
                      

                      }else{
                        if(!isPhoneNumberCorrect.value || isPhoneNumberEmpty.value 
                            || isNameEmpty.value || !isNameCorrect.value
                            || isPasswordEmpty.value){
                          Get.back();
                          return;
                        }else {

                          //중복 체크

                          //var emailResponse = await DioClient.checkEmail(phoneNumberController.text);
                          //var nicknameResponse = await DioClient.checkNickname(nicknameController.text);

                          // if(emailResponse.data["result"] is bool){
                          //   isPhoneNumberNotDuplicate.value = emailResponse.data["result"];
                          // }

                          // if(nicknameResponse.data["result"]["success"]){
                          //   isNicknameNotDuplicate.value = false;
                          // }

                          if(passwordController.text != passwordConfirmController.text) {
                            isPasswordConfirmCorrect.value = false;
                            Get.back();
                            return;
                          }

                          if(!isPhoneNumberNotDuplicate.value || !isNicknameNotDuplicate.value){
                            Get.back();
                            return;
                          }


                        }
                      }
                      signUpProcess();

                      

                    },
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Obx(() => Container(
                        decoration: BoxDecoration(
                            color: isAgreeTermOfServices.value && isAgreeToPersonalInfo.value ? ColorConstants.colorMain : ColorConstants.textGry,
                            borderRadius: BorderRadius.circular(4)),
                        height: 48,
                        width: Get.width ,
                        child: Center(
                          child: AppText(
                            text: "next".tr(),
                            fontSize: 16,
                            fontFamily: FontConstants.AppFont,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      )),
                    ),
                  ),
                  SizedBox(height: Get.height*0.02),
                ],
              ),
            ),
          ),
        )
    );
  }
}
