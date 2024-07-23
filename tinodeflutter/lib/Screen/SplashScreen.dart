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
import 'package:tinodeflutter/InAppPurchase/purchaseScreen.dart';
import 'package:tinodeflutter/Screen/Login/DefaultScreen.dart';
import 'package:tinodeflutter/Screen/Login/login.dart' as login;
import 'package:tinodeflutter/Screen/messageRoomListScreen.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/components/widget/dialog.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/page/base/base_state.dart';
import 'package:tinodeflutter/tinode/tinode.dart';

import '../../Constants/ColorConstants.dart';
import '../../Constants/Constants.dart';
import '../../Constants/ImageConstants.dart';
import '../../Constants/utils.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends BaseState<SplashPage> {

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
  }
  void init() async
  {
    //await connectWsTinode();
    load();
  }

   

  Future<bool> connectWsTinode() async{
  try{
    var key = apiKey;
    var host = hostAddres;
    var loggerEnabled = true;
    Tinode tinodeInstance = Tinode(
      'JadeChat',
      ConnectionOptions(host, key, secure: true),
      loggerEnabled,
      versionApp: versionApp,
      deviceLocale: deviceLocale,
    );
    await tinodeInstance.connect();
    tinode_global = tinodeInstance;
    print('Is Connected:' + tinode_global.isConnected.toString());
    return true;
  }
  catch(err)
  {
    print("$err");
    return false;
  }
  
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
    if(prefs.containsKey('token')) token = prefs.getString('token')!;
    if(prefs.containsKey('url_encoded_token')) url_encoded_token = prefs.getString('url_encoded_token')!;

  
    if (prefs.getBool('first_run') ?? true) {
      FlutterSecureStorage storage = FlutterSecureStorage();
      prefs.clear();
      await storage.deleteAll();
      await FirebaseAuth.instance.signOut();

      prefs.setBool('first_run', false);
    }
    if(prefs.containsKey('login_type'))
    {
      if(prefs.getInt('login_type')==0) // 0 : id , pw  // 1: firebase 
      {
        // id pw
        id_pw_loginProcesss();
        return;
      }
      else if(prefs.getInt('login_type')==1)
      {
        // firebase
        //밑으로 가서 파이어베이스 자동로그인
      }
    }

    //  Get.offAll(DefaultScreen(),transition: Transition.rightToLeft);
    //  return;

    User? user = await FirebaseAuth.instance.currentUser;
    if(user != null){
      try {

        String firebaseToken = "${await FirebaseAuth.instance.currentUser?.getIdToken()}";
        print("firebase login token : $firebaseToken ");
        //var response = await apiP.userInfo(token);
       // UserModel user = UserModel.fromJson(response.data["result"]["user"]);
        
       if(token!="")
       {
        //var response = await tinode_global.loginWithAccessToken(token);
        var response = await tinode_global.firebaseLogin(firebaseToken);
        token = response.params['token'];
        url_encoded_token = Uri.encodeComponent(response.params['token']);
        prefs.setString('token', token);
        prefs.setString('url_encoded_token', url_encoded_token);
        tinode_global.setDeviceToken(gPushKey); //fcm push token 던지기
        PurchaseScreen.instance.initPurchaseState(); // purchase item init

        print("ddd");
        Get.offAll(MessageRoomListScreen());
       }
       else{
          print("일로 오면 안돼");
          showToast('파이어베이스 로그인 미구현');
          Get.offAll(DefaultScreen(),transition: Transition.rightToLeft);
       }
       
         // Constants.getUserInfo(false,context, apiP);
        
      } catch(e) {
        print(e);
          Get.offAll(DefaultScreen(),transition: Transition.rightToLeft);
      }
    }else{

      // 파이어베이스 관련 설정 초기화 시키고 들어가야함. 만약 파이어베이스 토큰이 만료되어서 갱신하려는데 인터넷연결이 안되어있으면 갱신이 안됨, 
      //그럼 로그인화면으로 보내면서 파이어베이스 세팅 초기화해야함

      Get.offAll(DefaultScreen(),transition: Transition.rightToLeft);
    }
  }

  void id_pw_loginProcesss() async {
    final prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey('basic_id')) {
      id = prefs.getString('basic_id')!;
    }
    
    if(prefs.containsKey('basic_pw')) {
      pw = prefs.getString('basic_pw')!;
    }
    

  try {
      var result = await tinode_global.loginBasic(id, pw, null);
      print('User Id: ' + result.params['user'].toString());
      token = result.params['token'];
      url_encoded_token = Uri.encodeComponent(result.params['token']);
      prefs.setString('token', token);
      prefs.setString('url_encoded_token', url_encoded_token);
      prefs.setInt('login_type',0); // 0 : id , pw  // 1: firebase
      print("token : $token");
      print("url token : $url_encoded_token");
      showToast("login 완료");
      tinode_global.setDeviceToken(gPushKey); //fcm push token 던지기
      PurchaseScreen.instance.initPurchaseState(); // purchase item init
      Get.offAll(MessageRoomListScreen(
      ));
    } catch (err) {
      showToast("잘못 입력했습니다");
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
                Image.asset(ImageConstants.splashLogo,width: Get.width*0.5, fit: BoxFit.cover,),

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
