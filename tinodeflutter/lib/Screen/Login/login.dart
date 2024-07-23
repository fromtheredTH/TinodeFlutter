import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tinodeflutter/Constants/Constants.dart';
import 'package:tinodeflutter/Screen/BottomNavBarScreen.dart';
import 'package:tinodeflutter/Screen/Login/CreateAccountScreen.dart';
import 'package:tinodeflutter/Screen/Login/SignupScreen_id_pw.dart';
import 'package:tinodeflutter/Screen/Login/SignupTypeScreen.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:tinodeflutter/model/UserAuthModel.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/page/base/base_state.dart';
import '../messageRoomListScreen.dart';
import '../../tinode/tinode.dart';
import '../../tinode/src/models/message.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:http/http.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

import '../../../components/item/PositionRetainedScrollPhysics.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Login extends StatefulWidget {
  const Login({super.key, });

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends BaseState<Login> {

  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  
  TextEditingController emailController = TextEditingController();
  TextEditingController emailPwController = TextEditingController();

  String id = "";
  String pw = "";

  String versionApp = '1.0.0';
  String deviceLocale = 'en-US';

  RxBool isVisiblePassword = true.obs;
  bool isOnlySocial = true;
  bool isLoginIng = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  //  connectWsTinode();
  }

  // void connectWsTinode() async{
  //  var key = apiKey;
  //   var host = hostAddres;
  //   var loggerEnabled = true;
  //   tinode = Tinode(
  //     'JadeChat',
  //     ConnectionOptions(host, key, secure: true),
  //     loggerEnabled,
  //     versionApp: versionApp,
  //     deviceLocale: deviceLocale,
  //   );
  //   await tinode.connect();
  //   tinode_global = tinode;
  //   print('Is Connected:' + tinode.isConnected.toString());

  // }

  void id_pw_loginProcesss() async {
    final prefs = await SharedPreferences.getInstance();

    id = idController.value.text == "" ? "test500" : idController.value.text;
    pw = pwController.value.text == "" ? "qwer123!" : pwController.value.text;
 
  try {
      var result = await tinode_global.loginBasic(id, pw, null);
      prefs.setString('basic_id', id);
      prefs.setString('basic_pw', pw);
      
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
      Get.offAll(BottomNavBarScreen());
    } catch (err) {
      showToast("잘못 입력했습니다");
    }
  }

  // Future<void> onClickLogin() async {
  //   try {
  //     final data = await FirebaseAuth.instance.signInWithEmailAndPassword(
  //       email: emailController.text,
  //       password:emailPwController.text,
  //     );

  //     String token =
  //         "${await FirebaseAuth.instance.currentUser?.getIdToken()}";

  //     String device_id = "";
  //     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  //     if (Platform.isAndroid) {
  //       AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //       device_id = androidInfo.id;
  //       const _androidIdPlugin = AndroidId();
  //       device_id = await _androidIdPlugin.getId() ?? '';
  //     } else if (Platform.isIOS) {
  //       IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  //       device_id = iosInfo.identifierForVendor ?? '';
  //     }

  //    // var response = await apiP.userInfo(token);
  //     //UserModel user = UserModel.fromJson(response.data["result"]["user"]);

  //     if(isLoading) {
  //       Get.back();
  //       isLoading = false;
  //     }      
  //     final SharedPreferences prefs = await SharedPreferences.getInstance();
  //     prefs.setString('authProvider', "email");
  //     prefs.setString('id', emailController.text);
  //     prefs.setString('pwd', emailPwController.text);
  //     //Constants.getUserInfo(true, context, apiP);
     
  //   } on FirebaseAuthException catch (e) {
  //     print(e.code);
  //     if(isLoading) {
  //       Get.back();
  //       isLoading = false;
  //     }
  //     isLoginIng =false;
  //     showToast('${e.code}:${e.message ?? ''}');
  //   }
  // }

  // Future<void> socialLogin(UserSocialInfo userInfo) async {
  //   try {
  //     String token =
  //         "${await FirebaseAuth.instance.currentUser?.getIdToken()}";
  //    // var response = await apiP.userInfo(token);
  //     if(isLoading) {
  //           Get.back();
  //           isLoading = false;
  //         }
  //     //UserModel user = UserModel.fromJson(response.data["result"]["user"]);

  //     final SharedPreferences prefs = await SharedPreferences.getInstance();
  //     prefs.setString('authProvider', userInfo.authProvider.name);
  //     prefs.setString('accessToken', userInfo.accessToken ?? "");
  //     prefs.setString('idToken', userInfo.refreshToken ?? "");
  //   //  Constants.getUserInfo(true, context, apiP);
  //     Get.offAll(MessageRoomListScreen(tinode: tinode_global));
  //   } catch (e) {
  //     print(e);
  //     if(isLoading) {
  //       Get.back();
  //       isLoading = false;
  //     }
  //     isLoginIng = false;

  //     Get.to(CreateAccount(
  //       socialInfo: userInfo,
  //     ));
  //   }
  // }

  Future<bool> onKeyboardHide() async {
    if (keyboardIsVisible(context)) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
    return false;
  }


  bool isIDPWLogin= false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: AppText(text: "JadeChat"),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(children: [
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black)),
            padding:
                const EdgeInsets.only(left: 20, top: 12, bottom: 12, right: 10),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: idController,
                  cursorColor: Colors.black,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  onEditingComplete: () {},
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.center,
                  textInputAction: TextInputAction.done,
                  maxLength: 50,
                  decoration: InputDecoration(
                      counterText: "",
                      contentPadding: EdgeInsets.zero,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintText: 'input id',
                      isDense: true,
                      hintStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                      border: InputBorder.none),
                  onChanged: (text) {
                    setState(() {});
                  },
                ),
              ),
            ]),
          ),
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black)),
            padding:
                const EdgeInsets.only(left: 20, top: 12, bottom: 12, right: 10),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: pwController,
                  cursorColor: Colors.black,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  onEditingComplete: () {},
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.center,
                  textInputAction: TextInputAction.done,
                  maxLength: 50,
                  decoration: InputDecoration(
                      counterText: "",
                      contentPadding: EdgeInsets.zero,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintText: 'pw input',
                      isDense: true,
                      hintStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                      border: InputBorder.none),
                  onChanged: (text) {
                    setState(() {});
                  },
                ),
              ),
            ]),
          ),
          SizedBox(
            // SizedBox 대신 Container를 사용 가능
            width: 100,
            height: 40,
            child: FilledButton(
              onPressed: () {
                id_pw_loginProcesss();
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Text('login'),
            ),
          ),
          SizedBox(height: 30,),
          SizedBox(
            // SizedBox 대신 Container를 사용 가능
            width: 150,
            height: 40,
            child: FilledButton(
              onPressed: () {
                Get.to(SignUpScreen());
              },
              child: Text('옛날 회원가입'),
            ),
          ),
                    SizedBox(height: 30,),

          SizedBox(
            // SizedBox 대신 Container를 사용 가능
            width: 200,
            height: 40,
            child: FilledButton(
              onPressed: () {
                Get.to(SignupTypeScreen());
              },
              child: Text('파이어베이스 회원가입'),
            ),
          ),
        ]),
      ),
    );
  }
}
