import 'dart:async';
import 'dart:io';


import 'package:internet_connection_checker/internet_connection_checker.dart';

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
import 'package:tinodeflutter/firebase/firebase_options.dart';
import 'package:tinodeflutter/firebase/push_notification.dart';
import 'package:tinodeflutter/Screen/login.dart';
import 'package:tinodeflutter/services/social_service.dart';
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
    statusBarColor:ColorConstants.colorBg1, // Replace with your desired color
      statusBarBrightness: Platform.isIOS ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: Platform.isIOS ? Brightness.dark : Brightness.light
  ));

  //fcm
  await initFcm();

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


  // DiscoverUtils.getPosts().then(
  //         (value) {
  //       Constants.discoverPosts = value;
  //     }
  // );

  // Create customized instance which can be registered via dependency injection
  final InternetConnectionChecker customInstance =
  InternetConnectionChecker.createInstance(
    checkTimeout: const Duration(seconds: 1),
    checkInterval: const Duration(seconds: 1),
  );

  // Check internet connection with created instance
  execute(customInstance);
}

Future<void> initFcm() async {
  await PushNotificationService().setupInteractedMessage();
  FirebaseMessaging.onBackgroundMessage(PushNotificationService.firebaseMessagingBackgroundHandler);

  FirebaseMessaging.instance.getToken().then((token) {
    print('token:' + (token ?? ''));
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
  // Prints either InternetConnectionStatus.connected
  // or InternetConnectionStatus.disconnected

  // actively listen for status updates
  final StreamSubscription<InternetConnectionStatus> listener =
  InternetConnectionChecker().onStatusChange.listen(
        (InternetConnectionStatus status) {
      switch (status) {
        case InternetConnectionStatus.connected:
        // ignore: avoid_print
          print('Data connection is available.');
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

          Utils.showToast("네트워크 연결을 확인해 주세요");
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
      home:Login(title: "Tinode",),
      //navigatorObservers: <NavigatorObserver>[observer],
      themeMode: Platform.isIOS ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData(brightness: Platform.isIOS ? Brightness.dark : Brightness.light),
      navigatorKey: Constants.navigatorKey,
    );
  }
}