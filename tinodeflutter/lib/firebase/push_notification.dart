import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';


import 'package:event_bus_plus/res/event_bus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tinodeflutter/Constants/Constants.dart';
import 'package:tinodeflutter/call/CallService.dart';
import 'package:tinodeflutter/global/DioClient.dart';
import 'package:tinodeflutter/global/app_get_it.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:tinodeflutter/model/userModel.dart';

import 'firebase_options.dart';


// ignore: slash_for_doc_comments
/**
 * Documents added by Alaa, enjoy ^-^:
 * There are 3 major things to consider when dealing with push notification :
 * - Creating the notification
 * - Hanldle notification click
 * - App status (foreground/background and killed(Terminated))
 *
 * Creating the notification:
 *
 * - When the app is killed or in background state, creating the notification is handled through the back-end services.
 *   When the app is in the foreground, we have full control of the notification. so in this case we build the notification from scratch.
 *
 * Handle notification click:
 *
 * - When the app is killed, there is a function called getInitialMessage which
 *   returns the remoteMessage in case we receive a notification otherwise returns null.
 *   It can be called at any point of the application (Preferred to be after defining GetMaterialApp so that we can go to any screen without getting any errors)
 * - When the app is in the background, there is a function called onMessageOpenedApp which is called when user clicks on the notification.
 *   It returns the remoteMessage.
 * - When the app is in the foreground, there is a function flutterLocalNotificationsPlugin, is passes a future function called onSelectNotification which
 *   is called when user clicks on the notification.
 *
 * */
class PushNotificationService {
  ///When the app is background, you hear a notification

  
   @pragma('vm:entry-point')
  static Future onDidReceiveBackgroundNotificationResponse(NotificationResponse? details) async {
    if(details == null){
      return;
    }
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      'jadechat_notification_channel_id', // id
      'jadechat High Importance Notifications', // title
      description: 'This channel is used for jadechat important notifications.', // description
      importance: Importance.high,
    );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    var androidSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSSettings = const DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    var initSetttings = InitializationSettings(android: androidSettings, iOS: iOSSettings);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onDidReceiveNotificationResponse: (details) async {
          // This function handles the click in the notification when the app is in foreground
          // Get.toNamed(NOTIFICATIOINS_ROUTE);
          String? payload = details.payload;
          if (payload != null) {
            print('onMessageOpenedApp data: ${payload}');
            Map<String, dynamic> data = json.decode(payload);
            onClick(data);
          }
        });
    Map<String, dynamic> message = jsonDecode(details?.payload ?? "{}");
    String title = message["title"];
    String body = message["body"];
    try {
      final meta = jsonDecode(message['meta']);
      int fcmType = meta['fcmType'];
      // if (fcmType == 10) {
      //   int chatRoomId = meta['room']['id'];
      //   var response = await DioClient.getChatRoom(chatRoomId);
      //   ChatRoomDto room = ChatRoomDto.fromJson(response.data);
      //   var msgResponse = await DioClient.getChatRoomFromMessage(meta["chat"]["id"]);
      //   ChatMsgDto msg = ChatMsgDto.fromJson(msgResponse.data);
      //   getIt.registerSingleton(EventBus());
      //   if(msg.chat_idx == -1 ){
      //     getIt<EventBus>()
      //         .fire(ChatReceivedEvent(msg, room));
      //     return;
      //   }else {
      //     body = chatContent(msg.contents ?? "", msg.type);
      //     getIt<EventBus>()
      //         .fire(ChatReceivedEvent(msg, room));
      //     int id = Constants.user.id;
      //     int gChat = gChatRoomUid;
      //     if (gChatRoomUid == chatRoomId || msg.sender_id == Constants.user.id || title == "my_chat" || msg.type == 5 || title == "Leave") {
      //       //현재 입장한 채팅방의 채팅 푸시면 리턴
      //       return;
      //     }
      //   }
      // } else if (fcmType == 0) {
      //   //시스템 노티
      //   if (title == 'Leave' ) {
      //     // 방탈퇴
      //     try {
      //       int user_id = int.parse(body.split(",")[0].split(":")[1].trim());
      //       int room_id = int.parse(body.split(",")[1].split(":")[1].trim());
      //       getIt<EventBus>().fire(ChatLeaveEvent2(user_id, room_id));
      //     } catch (error) {}
      //   }
      //   return;
      // }
    } catch (e) {
      print(e);
      return;
    }
    flutterLocalNotificationsPlugin.show(
        details?.hashCode ?? 0,
        title,
        body,
        NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              priority: Priority.max,
              importance: Importance.max,
              channelDescription: channel.description,
              // icons: message.notification?.android?.smallIcon,
              playSound: true,
            ),
            iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true)),
        payload: jsonEncode(details?.payload ?? "{}"));
  }
  
  
  @pragma('vm:entry-point')
  static Future firebaseMessagingBackgroundHandler(RemoteMessage? message) async {
     
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
      
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('onMessageOpenedApp data: ${message.data}');
      onClick(message.data);
    });


    print('Handling a background message ${message?.messageId}');
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      'jadechat_notification_channel_id', // id
      'jadechat High Importance Notifications', // title
      description:
          'This channel is used for jadechat important notifications.', // description
      importance: Importance.high,
    );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    var androidSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSSettings = const DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    var initSetttings =
        InitializationSettings(android: androidSettings, iOS: iOSSettings);
  flutterLocalNotificationsPlugin.initialize(initSetttings,
        onDidReceiveNotificationResponse: (details) async {
      // This function handles the click in the notification when the app is in foreground
      // Get.toNamed(NOTIFICATIOINS_ROUTE);
      String? payload = details.payload;
      if (payload != null) {
        print('onMessageOpenedApp data: ${payload}');
        Map<String, dynamic> data = json.decode(payload);
         onClick(data);
      }
    });

    try {
      //bool isTinodeConnect = false;

      if(message ==null) return;
      //if(tinode_global==null) isTinodeConnect = await reConnectTinode();
     // if(message.data['xfrom'] == Constants.user.id) return;  // 내 메시지

      String _fcmType =  message.data['what'];
      int seq =  int.parse(message.data['seq']);
      String topic = message.data['topic'];
      String roomName = message.data['fn'];
      gBackgroundFcmTopic= topic;
      String ts = message.data['ts'];
      dynamic rc = jsonDecode(message.data['rc']);
      eChatType chatType = eChatType.NONE;

      if(rc['txt']==" ")
      {
          if(rc['ent']!=null)
          {
            switch(rc['ent'][0]['tp'])
              {
              case 'IM':
                print("image");
                chatType= eChatType.IMAGE;
                break;
              case 'VD':
                print("video");
                chatType= eChatType.VIDEO;
                break;
              case 'AU':
                print("audio");
                chatType= eChatType.AUDIO;
                break;
              default:
                chatType = eChatType.NONE;
                break;
              }
          }
      }
      else
      {
        chatType= eChatType.TEXT;
      }

        if(message.data['webrtc'] !=null)
        {
            // if(stringToBool(message.data['aonly'])) chatType= eChatType.VOICE_CALL;
            if(message.data['aonly']!=null)chatType= eChatType.VOICE_CALL;
            else chatType= eChatType.VIDEO_CALL;
        }
      
      if(chatType==eChatType.VOICE_CALL || chatType==eChatType.VIDEO_CALL)
      {
        Map<String,dynamic> callData;
        if(chatType==eChatType.VOICE_CALL )
        {
            callData={
              'room_id': topic,
              'room_name':roomName,
              "callType" : eChatType.VOICE_CALL.index,
            };
        }
        else // video call
        {
            callData={
              'room_id': topic,
              'room_name':roomName,
              "callType" : eChatType.VIDEO_CALL.index,
            };
        }
          saveData(topic,callData);
          CallService.instance.showIncomingCall(roomTopicId: topic, callerName : roomName ,callerNumber: '', callerAvatar: "");
          return;
      }
      try{
      String body = chatContent(chatType==eChatType.TEXT ? rc['txt'] :"", chatType);
      int notiId = stringToAsciiSum(topic);
      flutterLocalNotificationsPlugin.show(
              notiId,
              topic,
              body,
              NotificationDetails(
                  android: AndroidNotificationDetails(
                    channel.id,
                    channel.name,
                    priority: Priority.high,
                    importance: Importance.high,
                    channelDescription: channel.description,
                  //  tag: (meta['room']['id']).toString(),
                    // icons: message.notification?.android?.smallIcon,
                    playSound: true,
                  ),
                  iOS: DarwinNotificationDetails(
                      presentAlert: true,
                      presentBadge: true,
                      presentSound: true)),
              payload: jsonEncode(message.data));
      }
      catch(err){
        print("err : $err");
      }

      // RemoteNotification? notification = message!.notification;
      // // String body = notification?.body ?? '';
      // String contentBody="" ;
      // final meta = jsonDecode(message!.data['meta']);
      // int fcmType = meta['fcmType'];
      // String title = (message.data['title']) ?? "";
        
      // if(fcmType==0 && title=='expire-chat')
      //   {
      //     final dataBody = jsonDecode(message.data['body']) ?? "";
      //     if( dataBody['first_chat_id'] ==-1) {
      //       //flutterLocalNotificationsPlugin.cancelAll();
      //       flutterLocalNotificationsPlugin.cancel(dataBody['room_id'],); // 플러그인의 함수에서 만약 없는 푸시를 삭제한다고 해도 예외처리가 되어있음을 확인했음
      //     }
      //     return;
      //   } else
      //   {
      //   contentBody =  (message.data['body']) ?? "";
      //   }


        
      
    } catch (e) {
      print(e);
    }
  }

  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    await Firebase.initializeApp();

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
     PushNotificationService.onClick(initialMessage.data);
    }
   
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('onMessageOpenedApp data: ${message.data}');
      onClick(message.data);
    });
    // FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
    //   print('Handling a background message ${message.messageId}');
    // });
    await enableIOSNotifications();
    await registerNotificationListeners();
  }

  static void onClick(Map<String, dynamic> data) async {
    print(data);
    gPushClick = true;
    final meta = jsonDecode(data['meta']);
    int fcmType = meta['fcmType'];
    String link = data['link'];
    // link = link.replaceAll("zempie.com", "namjungkim.github.io");
    // if (fcmType == 10) {
    //   // 채팅
    //   //dm
    //   int chatRoomId = meta['room']['id'];
    //   gPushClickMsgId = meta['chat']['id'];
    //   if (gChatRoomUid == chatRoomId) {
    //     //현재 입장한 채팅방의 채팅 푸시면 리턴
    //     return;
    //   }
    //   dynamic membership = await DioClient.getMembershipData();
    //   if (!membership.data['result']['has_membership']) {
    //     showToast("membership over");
    //     //  getIt<EventBus>()
    //     //       .fire(ChatPushClickEvent(false));

    //     return;
    //   }

  }


  registerNotificationListeners() async {
    AndroidNotificationChannel channel = androidNotificationChannel();
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    
    // android iOS 초기화
    var androidSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSSettings = const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    var initSetttings =
    InitializationSettings(android: androidSettings, iOS: iOSSettings);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onDidReceiveNotificationResponse: (details) async {
      // This function handles the click in the notification when the app is in foreground
      // Get.toNamed(NOTIFICATIOINS_ROUTE);
      String? payload = details.payload;
      print("payload : ${payload}");
      if (payload != null) {
        print('onMessageOpenedApp data: ${payload}');
        Map<String, dynamic> data = json.decode(payload);
        onClick(data);
      }
    },
    onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse
    );
// onMessage is called when the app is in foreground and a notification is received
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) async{
      // WriteLog.write("fcm come time:  ${DateTime.now()}\n message : ${message} \n  ",fileName: 'fcmCome.txt');

      //RemoteNotification? notification = message!.notification;
   
      //String body = notification?.body ?? '';
        bool isTinodeConnect = false;
        if(message ==null)
        {
          return;
        }
        if(!tinode_global.isConnected)
        {
        isTinodeConnect = await reConnectTinode();
        }else isTinodeConnect=true;

        if(isTinodeConnect && message.data['xfrom'] == tinode_global.userId) return;  // 내 메시지

        String _fcmType =  message.data['what'];
        int seq =  int.parse(message.data['seq']);
        String topic = message.data['topic'];
        String ts = message.data['ts'];
        dynamic rc = jsonDecode(message.data['rc']);
        eChatType chatType = eChatType.NONE;

        if(rc['txt']==" ")
        {
          if(rc['ent']!=null)
          {
            switch(rc['ent'][0]['tp'])
              {
              case 'IM':
                print("image");
                chatType= eChatType.IMAGE;
                break;
              case 'VD':
                print("video");
                chatType= eChatType.VIDEO;
                break;
              case 'AU':
                print("audio");
                chatType= eChatType.AUDIO;
                break;
              default:
                chatType = eChatType.NONE;
                break;
              }
          }
          
        }
        else
        {
          chatType= eChatType.TEXT;
        }
        try{
        if(message.data['webrtc'] !=null)
        {
            print("call");
            //if(stringToBool(message.data['aonly'])) chatType= eChatType.VOICE_CALL;
            if(message.data['aonly']!=null)chatType= eChatType.VOICE_CALL;
            else chatType= eChatType.VIDEO_CALL;

        }
        
        if(chatType==eChatType.VOICE_CALL || chatType==eChatType.VIDEO_CALL)
        {

          
          if(isTinodeConnect)
          {
            if(chatType ==eChatType.VOICE_CALL)
            CallService.instance.chatType = eChatType.VOICE_CALL;
            else
            CallService.instance.chatType = eChatType.VIDEO_CALL;

            List<UserModel> joinUserList = [];
            CallService.instance.joinUserList = joinUserList;
            CallService.instance.roomTopicName = topic;
            CallService.instance.initCallService();
            CallService.instance.showIncomingCall(roomTopicId: topic, callerName : topic ,callerNumber: '', callerAvatar: "");
            
          }
        }
        }
        catch(err)
        {
          print("err");
        }
        
        try{
        String body = chatContent(chatType==eChatType.TEXT ? rc['txt'] :"", chatType);
        int notiId = stringToAsciiSum(topic);
        flutterLocalNotificationsPlugin.show(
                notiId,
                topic,
                body,
                NotificationDetails(
                    android: AndroidNotificationDetails(
                      channel.id,
                      channel.name,
                      priority: Priority.high,
                      importance: Importance.high,
                      channelDescription: channel.description,
                    //  tag: (meta['room']['id']).toString(),
                      // icons: message.notification?.android?.smallIcon,
                      playSound: true,
                    ),
                    iOS: DarwinNotificationDetails(
                        presentAlert: true,
                        presentBadge: true,
                        presentSound: true)),
                payload: jsonEncode(message.data));
        }
        catch(err){
          print("err : $err");
        }
    

      // String contentBody="" ;
      // final meta = jsonDecode(message.data['meta']) ?? "";
      // String title = (message.data['title']) ?? ""; // data 의 title
      // int fcmType = meta['fcmType'];
        
      //   if(fcmType==0 && title=='expire-chat')
      //   {
      //     final dataBody = jsonDecode(message.data['body']) ?? "";
      //     if(dataBody['first_chat_id'] ==-1) {
      //       //flutterLocalNotificationsPlugin.cancelAll();
      //       flutterLocalNotificationsPlugin.cancel(dataBody['room_id'],); // 플러그인의 함수에서 만약 없는 푸시를 삭제한다고 해도 예외처리가 되어있음을 확인했음
      //     }
      //     return;
      //   }
      //   else
      //   {
      //   contentBody =  (message.data['body']) ?? "";
      //   }

  
      try {    
        // if (fcmType == 10) {
        //   if (meta["chat"]["chat_idx"] == -1) {
        //     getIt<EventBus>().fire(ChatReceivedEvent(
        //         ChatMsgDto.fromJson(meta['chat']),
        //         ChatRoomDto.fromJson(meta['room'])));

        //     return;
        //   } else {
        //     contentBody = chatContent(meta['chat']['contents'], meta['chat']['type']);

        //     int chatRoomId = meta['room']['id'];
        //     getIt<EventBus>().fire(ChatReceivedEvent(
        //         ChatMsgDto.fromJson(meta['chat']),
        //         ChatRoomDto.fromJson(meta['room'])));
        //     int id = Constants.user.id;
        //     int gChat = gChatRoomUid;
        //     if (gChatRoomUid == chatRoomId ||
        //         meta["chat"]["sender_id"] == Constants.user.id ||
        //         (title ?? "") == "my_chat" ||
        //         meta['chat']['type'] == 5 || (title ?? "") == "Leave") {
        //       //현재 입장한 채팅방의 채팅 푸시면 리턴
        //       //현재 입장한 채팅방의 채팅 푸시면 리턴
        //       return;
        //     }
        //   }
        // } else if (fcmType == 0) {
        //   //시스템 노티
        //   if ((title ?? '') == 'Leave') {
        //     // 방탈퇴
        //     try {
        //       int user_id = int.parse(contentBody.split(",")[0].split(":")[1].trim());
        //       int room_id = int.parse(contentBody.split(",")[1].split(":")[1].trim());

        //       getIt<EventBus>().fire(ChatLeaveEvent2(user_id, room_id));
        //     } catch (error) {}
        //   }
        //   return;
        // }
      } catch (e) {
        print(e);
        return;
      }
    });
  }

  enableIOSNotifications() async {
    // iOS 권한요청 , android는 알아서 해줌
    await FirebaseMessaging.instance
        .requestPermission(
      alert: false,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: false,
    )
        .then((settings) {
      print('User granted permission: ${settings.authorizationStatus}');
    });

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: false, // Required to display a heads up notification
      badge: false,
      sound: false,
      
    );
  }

  androidNotificationChannel() => const AndroidNotificationChannel(
        'jadechat_notification_channel_id', // id
        'jadechat high Importance Notifications', // title
        description:
            'This channel is used for jadechat important notifications.', // description
        importance: Importance.high,
      );
}
