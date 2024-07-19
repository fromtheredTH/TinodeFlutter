import 'package:dio/dio.dart';
import 'package:event_bus_plus/event_bus_plus.dart';
import 'package:flutter/widgets.dart';

import 'package:get/get.dart' hide Trans;
import 'package:tinodeflutter/Constants/utils.dart';
import 'package:tinodeflutter/Screen/SplashScreen.dart';
import 'package:tinodeflutter/global/app_get_it.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:tinodeflutter/tinode/src/services/connection.dart';
import 'package:tinodeflutter/tinode/tinode.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> with WidgetsBindingObserver {
  // final ApiC apiC = getIt<ApiC>();
  // final ApiP apiP = getIt<ApiP>();
  bool isLoading = false;
  // final event = getIt<EventBus>();
  // final dio = getIt<Dio>();



  void showLoading() {
    Utils.showDialogWidget(context);
    isLoading=true;
  }

  void hideLoading() {
    if(isLoading)
    {
      isLoading=false;
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
  
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);

  }
  
   @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
       case AppLifecycleState.resumed:
       showToast("forground resumed");
        try{
          if(!tinode_global.isConnected)
            {
              showToast('웹 소켓 연결 시도 중 ...');
              Utils.showDialogWidget(context);
              await tinode_global.connect();
              Get.back();
              showToast('웹 소켓 연결 완료!');
            }
            else
            {
              showToast('웹소켓 연결 OK 상태...');
            }
          }
          catch(err){
            showToast('fail to connect');
            Get.offAll(SplashPage());
          }
        break;
      default:
        break;
    }
    
  }




}
