import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/src/public_ext.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinodeflutter/Screen/Login/login.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/components/widget/dialog.dart';
import 'package:tinodeflutter/model/userModel.dart';

import '../../Constants/ColorConstants.dart';
import '../../Constants/Constants.dart';
import '../../Constants/ImageConstants.dart';
import '../../Constants/utils.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> load() async {
   // var response = await DioClient.getVersion();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String recentVersion = "";
    // if(Platform.isAndroid){
    //   recentVersion = response.data["result"]["android"];
    // }else{
    //   recentVersion = response.data["result"]["ios"];
    // }
    List<String> versions = packageInfo.version.split(".");
    List<String> recentVersions = recentVersion.split(".");
    if(versions.length >= 2 && recentVersions.length >= 2 && (versions[0] != recentVersions[0] || versions[1] != recentVersions[1])){
      AppDialog.showOneDialog(context, "version_title".tr(), "version_description".tr(), () {
        if(Platform.isAndroid){
          Utils.urlLaunch("https://play.google.com/store/apps/details?id=com.widblack.jadechat");
        }else{
          Utils.urlLaunch("https://apps.apple.com/us/app/jadechat/id6499414852");
        }
      });
      return;
    }
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('first_run') ?? true) {
      FlutterSecureStorage storage = FlutterSecureStorage();

      await storage.deleteAll();
      await FirebaseAuth.instance.signOut();

      prefs.setBool('first_run', false);
    }

    Get.off(Login(),transition: Transition.rightToLeft);
    return;

    User? user = await FirebaseAuth.instance.currentUser;
    if(user != null){
      try {

        String token = " ${await FirebaseAuth.instance.currentUser?.getIdToken()}";
        print("firebase login token : $token ");
        //var response = await apiP.userInfo(token);
       // UserModel user = UserModel.fromJson(response.data["result"]["user"]);

        
         // Constants.getUserInfo(false,context, apiP);
        
      } catch(e) {
        print(e);
        Get.off(Login(),transition: Transition.rightToLeft);
      }
    }else{
      Get.off(Login(),transition: Transition.rightToLeft);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      body: Stack(
        children: [
          Center(
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(ImageConstants.splashLogo,width: Get.width*0.3, fit: BoxFit.cover,),

                SizedBox(height: 20,),
                AppText(
                    text: "당신만을 위한 채팅 앱, JadeChat에서 대화의 즐거움을 경험하세요!",
                  fontSize: 13,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
