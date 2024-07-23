import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/date_time_patterns.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_links/app_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tinodeflutter/Constants/ColorConstants.dart';
import 'package:tinodeflutter/Constants/Constants.dart';
import 'package:tinodeflutter/Screen/SplashScreen.dart';
import 'package:tinodeflutter/firebase/firebase_options.dart';
import 'package:tinodeflutter/firebase/push_notification.dart';
import 'package:tinodeflutter/Screen/Login/login.dart';
import 'package:tinodeflutter/services/social_service.dart';
import 'package:tinodeflutter/tinode/src/services/connection.dart';
import 'package:tinodeflutter/tinode/tinode.dart';
import 'package:uni_links/uni_links.dart';
import 'package:intl/intl_standalone.dart';
import 'Constants/utils.dart';
import 'call/CallScreen.dart';
import 'call/CallService.dart';
import 'global/app_get_it.dart';
import 'global/global.dart';
import 'helpers/common_util.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  // name: 'jade-chat',
  options: DefaultFirebaseOptions.currentPlatform,
);
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform
  // );
  await EasyLocalization.ensureInitialized();
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  GetIt.I.registerSingleton<SocialService>(SocialService());
  setupLocator();
  await Permission.notification.request(); // 유저 승인 요청 후 initFcm()

 SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  statusBarColor: Colors.white, // 상태바 배경색을 흰색으로 설정
  statusBarBrightness: Brightness.light, // iOS에서 상태바 콘텐츠를 어둡게 (검은색)
  statusBarIconBrightness: Brightness.dark, // Android에서 상태바 아이콘을 어둡게 (검은색)
));

  await connectWsTinode(); //웹소켓 연결

  // Create customized instance which can be registered via dependency injection
  final InternetConnectionChecker customInstance =
  InternetConnectionChecker.createInstance(
    checkTimeout: const Duration(seconds: 1),
    checkInterval: const Duration(seconds: 1),
  );

  // Check internet connection with created instance
  execute(customInstance); // 인터넷 체크 리스너 등록
  

  //fcm
  await initFcm();
    ConnectionService connectionService = tinode_global.getConnectionService();
    // WebSocket 연결 상태 감지
    connectionService.onConnectionLost.listen((_) async {
      print('WebSocket 연결이 끊어졌습니다.');
      showToast('연결 끊김 웹소켓');
      // 여기에 연결이 끊어졌을 때 수행할 작업을 추가합니다.
       try{
          if(!tinode_global.isConnected)
            {
              showToast('웹 소켓 연결 시도 중 ...');
              // Utils.showDialogWidget(context);
              await tinode_global.connect();
              // Get.back();
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
    });

  findSystemLocale().then((value) {
    print("로케이션 값음 ${value}");
    Intl.systemLocale = "en_US";
  });

  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ko')],
        path: 'assets/translations',
        // <-- change the path of the translation files
       // fallbackLocale: const Locale('en'),
        fallbackLocale: const Locale('ko'),
        child: MyApp()),
  );

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );
  final _storage = new FlutterSecureStorage(aOptions: _getAndroidOptions());
  String language = await _storage.read(key: "language") ?? "";
  String translationCode = await _storage.read(key: "translationCode") ?? "";
  String translationName = await _storage.read(key: "translationName") ?? "";
  Constants.cachingKey = DateTime.now().millisecondsSinceEpoch.toString();
  if(language.isEmpty){
    String languageCode = PlatformDispatcher.instance.locale.languageCode;
    _storage.write(key: "language", value: languageCode);
    if(languageCode != "ko"){
      languageCode = "en";
    }
    language = languageCode;
    translationCode = languageCode;
    if(translationCode == "ko"){
      translationName = "한국어";
    }else{
      translationName = "English";
    }
    
    _storage.write(key: "translationCode", value: translationCode);
    _storage.write(key: "translationName", value: translationName);
  }
  language="ko";  // 일단 한국어로 fix
  Constants.languageCode = language;
  Constants.translationCode = translationCode;
  Constants.translationName = translationName;

  Timer? _timer;
  

    // 이미 실행 중인 타이머가 있다면 취소
    // _timer?.cancel();
    
    // 5초마다 반복하는 새 타이머 시작
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      DateTime beforeTime = DateTime.now();
      var response = await tinode_global.ping();
      DateTime afterTime = DateTime.now();
      Duration difference = afterTime.difference(beforeTime);
      pingMiliSeconds = difference.inMilliseconds;

      print("pingMiliSeconds : $pingMiliSeconds");
    });
  


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

Future<void> initFcm() async {
  await PushNotificationService().setupInteractedMessage();
  FirebaseMessaging.onBackgroundMessage(PushNotificationService.firebaseMessagingBackgroundHandler);
    // flutter_callkit_incoming 이벤트 리스너 설정
    try{
    FlutterCallkitIncoming.onEvent.listen((event) async {
    if (event?.event == Event.actionCallAccept) {
      // 앱이 백그라운드에서 시작될 때 호출
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if(!prefs.containsKey('call')) showToast('call 데이터가 prefs에 저장되어있지 않음');
      String? jsonString = prefs.getString('call');
      Map<String, dynamic> _data = jsonDecode(jsonString ?? "");
      String roomTopicId = _data['room_id'];

      // roomtopic name 설정이 안되어있음
      CallService.instance.roomTopicName = roomTopicId;
      bool isSetDone = await CallService.instance.initCallService();
      // CallScreen으로 네비게이트
      Get.to(() => CallScreen(
        tinode: tinode_global,
        roomTopicName: roomTopicId,
        joinUserList: [],
        chatType: eChatType.values[_data['callType']],
      ));
    }
  });
    }
    catch(err)
    {
      print("dd");
    }
 

  FirebaseMessaging.instance.getToken().then((token) {
    print('fcm token:' + (token ?? ''));
    //LocalService.setToken((token ?? ''));
    gPushKey = (token ?? '');
  });
}


Future<void> execute(
    InternetConnectionChecker internetConnectionChecker
    ) async {
  // Simple check to see if we have Internet
  // ignore: avoid_print
  print('''The statement 'this machine is connected to the Internet' is: ''');
  final bool isConnected = await InternetConnectionChecker().hasConnection;
  // ignore: avoid_print
  print(
    isConnected.toString(),
  );
  // returns a bool

  // We can also get an enum instead of a bool
  // ignore: avoid_print
  print(
    'Current status: ${await InternetConnectionChecker().connectionStatus}',
  );
  if(await InternetConnectionChecker().connectionStatus == InternetConnectionStatus.disconnected)
  showToast('인터넷 연결이 안 되어있습니다.');
  // Prints either InternetConnectionStatus.connected
  // or InternetConnectionStatus.disconnected

  // actively listen for status updates
  final StreamSubscription<InternetConnectionStatus> listener =
  InternetConnectionChecker().onStatusChange.listen(
        (InternetConnectionStatus status) async {
      switch (status) {
        case InternetConnectionStatus.connected:
        // ignore: avoid_print
          print('Data connection is available.');
          showToast('인터넷 OK');
          break;
        case InternetConnectionStatus.disconnected:
        // ignore: avoid_print
        //   var snackBar = SnackBar(
        //       backgroundColor: ColorConstants.red,
        //       behavior: SnackBarBehavior.floating, content: Row(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       SizedBox(width: 10,),
        //       Icon(Icons.wifi_off_rounded, size: 16, color: Colors.white,),
        //       Expanded(
        //           child: AppText(
        //             text: "네트워크 연결을 확인해 주세요",
        //           )
        //       ),
        //       SizedBox(width: 10,),
        //     ],
        //   ));

        try{
          if(!tinode_global.isOpen || !tinode_global.isConnected)
            {
              showToast('웹 소켓 연결 시도 중 ...');
              // Utils.showDialogWidget(context);
            var result =  await tinode_global.connect();
              // Get.back();
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

          showToast("네트워크 연결을 확인해 주세요");
          break;
      }
    },
  );

  // close listener after 30 seconds, so the program doesn't run forever
  await Future<void>.delayed(const Duration(seconds: 30));
  await listener.cancel();
}

class MyApp extends StatelessWidget {

  // static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  // static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'jade-chat',
      // home:SplashPage(),
      home:SplashPage(),
      //navigatorObservers: <NavigatorObserver>[observer],
      themeMode: ThemeMode.light, //Platform.isIOS ? ThemeMode.light : ThemeMode.light,
      darkTheme: ThemeData(brightness: Platform.isIOS ? Brightness.dark : Brightness.light),
      navigatorKey: Constants.navigatorKey,
    );
  }
}