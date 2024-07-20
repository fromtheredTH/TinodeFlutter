
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:tinodeflutter/Screen/Login/forgot_controller.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/utils.dart';

class ForgetScreen extends StatelessWidget {
   ForgetScreen({super.key});
  ForgotController controller=Get.put(ForgotController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Color(0xFFF1A1C29),
        body: Padding(
          padding:  EdgeInsets.symmetric(vertical: 10,horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 40,
                ),
                InkWell(
                  onTap: (){
                    Get.back();
                  },
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back_ios, color:Colors.white ),
                      Text("find_password".tr(),style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: FontConstants.AppFont,
                      ),)
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Center(
                  child: Text(
                    "resetting_password".tr(),
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: FontConstants.AppFont,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                    "resetting_password_email_guide".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: FontConstants.AppFont,
                    color:Color(0xFFFFFFFF).withOpacity(0.5),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                TextField(
                  style: TextStyle(
                    color: Color(0xFFFFFFFF).withOpacity(0.7),
                  ),
                  controller: controller.emailController,
                    cursorColor: Colors.grey,
                  decoration: InputDecoration(
                    border:UnderlineInputBorder(),
                    hintText: "email_address".tr(),
                    hintStyle: TextStyle(
                      color: Color(0xFFFFFFFFF).withOpacity(0.7),
                    ),
                  ),
                ).paddingSymmetric(horizontal:15),
                Obx(() => Text(controller.emailValidationText.value,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Color(0xFFEB5757),
                  ),
                ).paddingOnly(left: 10),),
                SizedBox(
                  height: 90,
                ),
                GestureDetector(
                  onTap: (){
                    if (!EmailValidator.validate(controller.emailController.text,true)) { // Use EmailValidator.validate() to validate email
                      controller.emailValidationText.value="email_guide_incorrect".tr();
                    }
                    else {
                      FirebaseAuth.instance.sendPasswordResetEmail(email: controller.emailValidationText.value).then((error) {
                        controller.emailValidationText.value = "";
                        Get.back();
                        Utils.showToast("toast_edit_password_email".tr());
                      });
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Color(0xFFE99315),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        "send_email".tr(),
                        style: TextStyle(
                          color: Color(0xFFFFFFFFF),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          fontFamily: FontConstants.AppFont
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ));
  }
}
