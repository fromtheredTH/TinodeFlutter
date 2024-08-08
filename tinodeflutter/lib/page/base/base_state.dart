import 'dart:async';

import 'package:dio/dio.dart';
import 'package:event_bus_plus/event_bus_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import 'package:get/get.dart' hide Trans;
import 'package:tinodeflutter/Constants/utils.dart';
import 'package:tinodeflutter/Screen/Login/DefaultScreen.dart';
import 'package:tinodeflutter/Screen/SplashScreen.dart';
import 'package:tinodeflutter/global/app_get_it.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:tinodeflutter/tinode/src/services/connection.dart';
import 'package:tinodeflutter/tinode/tinode.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  // final ApiC apiC = getIt<ApiC>();
  // final ApiP apiP = getIt<ApiP>();
  bool isLoading = false;
  // final event = getIt<EventBus>();
  // final dio = getIt<Dio>();
  bool isMessageRoomScreenOn=false;

  late StreamSubscription<int> pingSubscription;
  RxInt base_pingMiliSeconds =0.obs;
 
  void pingListen()
  {
      pingSubscription = pingSubject.listen((pingMilliseconds) {
      print('SomeOtherClass received ping: $pingMilliseconds ms');
      base_pingMiliSeconds.value = pingMilliseconds;
      // 여기서 필요한 작업을 수행합니다.
      // setState(() {
        
      // });
    });
  }

  void showLoading() {
    Utils.showDialogWidget(context);
    isLoading = true;
  }

  void hideLoading() {
    if (isLoading) {
      isLoading = false;
      Get.back();
    }
  }
  

  void hideKeyboard() {
    if (keyboardIsVisible(context)) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    pingListen();
  }

  @override
  void dispose() {
    pingSubscription.cancel();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  DateTime? _lastPausedTime;

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        _lastPausedTime = DateTime.now();
        break;

      case AppLifecycleState.resumed:
      //  showToast("forground resumed");
        if (_lastPausedTime != null) {
          final difference = DateTime.now().difference(_lastPausedTime!);
          if(difference.inSeconds>10) // 10초 이상 백그라운드 상태일 때
          {
          try {
              if (!tinode_global.isConnected && !isConnectProcessing_global) {
          //     showToast('웹 소켓 연결 시도 중 ...');
                isConnectProcessing_global = true;
                Utils.showDialogWidget(context);
                await tinode_global.connect();
                isConnectProcessing_global=false;
                try {
              //    showToast('re login 중 ...');
                  var response = await tinode_global.loginWithAccessToken(token);
                  final prefs = await SharedPreferences.getInstance();
                  token = response.params['token'];
                  url_encoded_token = Uri.encodeComponent(response.params['token']);
                  prefs.setString('token', token);
                  prefs.setString('url_encoded_token', url_encoded_token);
            //      showToast('re login 완료...');
                } catch (err) {
                  showToast('기존 토큰 만료 최초 로그인 프로세스 relogin');
                  reLogin();
                }
                Get.back();
                showToast('웹 소켓 연결 완료!');
              }else if(tinode_global.isConnected&& isConnectProcessing_global)
              {
                showToast('연결중..');
              }
               else {
                showToast('웹소켓 연결 OK 상태...');
              }
            } catch (err) {
              showToast('fail to connect');
              Get.offAll(SplashPage());
            }
          }
          _lastPausedTime=null;
        }
        break;
      default:
        break;
    }
  }

  // Future<bool> reLogin() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   try {
  //     if (prefs.getInt('login_type') == 0) // 0 : id , pw  // 1: firebase
  //     {
  //       id_pw_Login(prefs);
  //       return true;
  //     } else if (prefs.getInt('login_type') == 1) {
  //       // firebase
  //       firebaseLogin(prefs);
  //       return true;
  //     }
  //     showToast('여기는 들어오는 곳 아님');
  //     return false; // 여기는 들어오면 안됨
  //   } catch (err) {
  //     print("re login err : $err");
  //     showToast('re login err  $err');
  //     return false;
  //   }
  // }

  // void firebaseLogin(SharedPreferences prefs) async {
  //   User? user = await FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     try {
  //       String firebaseToken =
  //           "${await FirebaseAuth.instance.currentUser?.getIdToken()}";
  //       // print("firebase login token : $firebaseToken ");
  //       if (token != "") {
  //         var response = await tinode_global.firebaseLogin(firebaseToken);
  //         token = response.params['token'];
  //         url_encoded_token = Uri.encodeComponent(response.params['token']);
  //         prefs.setString('token', token);
  //         prefs.setString('url_encoded_token', url_encoded_token);
  //         showToast('파이어베이스 재 로그인 완료');
  //           } else {
  //         print("일로 오면 안돼");
  //         showToast('파이어베이스 로그인 미구현');
    
  //         Get.offAll(SplashPage(), transition: Transition.rightToLeft);
  //       }

  //       // Constants.getUserInfo(false,context, apiP);
  //     } catch (e) {
  //       print(e);
  //       Get.offAll(SplashPage(), transition: Transition.rightToLeft);
  //       }
  //   }
  // }

  // void id_pw_Login(SharedPreferences prefs) async {
  //   if (prefs.containsKey('basic_id')) {
  //     id = prefs.getString('basic_id')!;
  //   }

  //   if (prefs.containsKey('basic_pw')) {
  //     pw = prefs.getString('basic_pw')!;
  //   }

  //   try {
  //     var result = await tinode_global.loginBasic(id, pw, null);
  //     // print('User Id: ' + result.params['user'].toString());
  //     token = result.params['token'];
  //     url_encoded_token = Uri.encodeComponent(result.params['token']);
  //     prefs.setString('token', token);
  //     prefs.setString('url_encoded_token', url_encoded_token);
  //     // print("token : $token");
  //     // print("url token : $url_encoded_token");
  //     showToast("relogin 완료");
  //   } catch (err) {
  //     showToast("id pw 리 로그인 실패");
  //     Get.offAll(SplashPage(), transition: Transition.rightToLeft);
  //   }
  // }
}
