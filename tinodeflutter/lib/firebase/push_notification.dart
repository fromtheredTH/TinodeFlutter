import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';


import 'package:event_bus_plus/res/event_bus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tinodeflutter/call/CallService.dart';
import 'package:tinodeflutter/global/DioClient.dart';
import 'package:tinodeflutter/global/app_get_it.dart';
import 'package:tinodeflutter/global/global.dart';
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

    
 if (message != null) {
    final meta = jsonDecode(message!.data['meta'] ?? {});
    int fcmType = meta['fcmType'];
    String title = message.data['title'];
   if(fcmType==0 ) // fcmtype 이 0 일때와 아닐 때의 데이터가 달라서 한번 걸러 줘야함
    {
      
    }
     else if (meta["chat"]["type"] == 5) {
        return;
    }
    else if ((title ?? "") == "my_chat" || (title ?? "") == "Leave") {
      return;
    }
  }
    // if ((message?.notification?.title ?? "") == "my_chat" ||
    //     (message?.notification?.title ?? "") == "Leave") {
    //   return;
    // }

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
      RemoteNotification? notification = message!.notification;
      // String body = notification?.body ?? '';
      String contentBody="" ;
      final meta = jsonDecode(message!.data['meta']);
      int fcmType = meta['fcmType'];
      String title = (message.data['title']) ?? "";
        
      if(fcmType==0 && title=='expire-chat')
        {
          final dataBody = jsonDecode(message.data['body']) ?? "";
          if( dataBody['first_chat_id'] ==-1) {
            //flutterLocalNotificationsPlugin.cancelAll();
            flutterLocalNotificationsPlugin.cancel(dataBody['room_id'],); // 플러그인의 함수에서 만약 없는 푸시를 삭제한다고 해도 예외처리가 되어있음을 확인했음
          }
          return;
        } else
        {
        contentBody =  (message.data['body']) ?? "";
        }


      if (fcmType == 10) {
        if(tinode_global.isConnected){ 
          await reConnectTinode();
          List<User> joinUserList = [];
          CallService.instance.joinUserList = joinUserList;
          CallService.instance.roomTopicName = "";
          CallService.instance.initCallService();
          CallService.instance.showIncomingCall(callerName : title ,callerNumber: '', callerAvatar: "");
      }
        //dm
        // SendPort? send1 = IsolateNameServer.lookupPortByName('firbase_port1');
        // send1?.send([jsonEncode(meta['chat']), jsonEncode(meta['room'])]);
        SendPort? send2 = IsolateNameServer.lookupPortByName('firbase_port2');
        send2?.send([jsonEncode(meta['chat']), jsonEncode(meta['room'])]);

        SendPort? sendHome =
            IsolateNameServer.lookupPortByName('firbase_port_home');
        sendHome?.send([jsonEncode(meta['chat']), jsonEncode(meta['room'])]);

        SendPort? sendDiscover =
            IsolateNameServer.lookupPortByName('firbase_port_discover');
        sendDiscover
            ?.send([jsonEncode(meta['chat']), jsonEncode(meta['room'])]);

        SendPort? sendCommunity =
            IsolateNameServer.lookupPortByName('firbase_port_community');
        sendCommunity
            ?.send([jsonEncode(meta['chat']), jsonEncode(meta['room'])]);

        SendPort? sendNotification =
            IsolateNameServer.lookupPortByName('firbase_port_notification');
        sendNotification
            ?.send([jsonEncode(meta['chat']), jsonEncode(meta['room'])]);

        // if (meta["chat"]["chat_idx"] == -1) {
        //   return;
        // } else {
        //   contentBody = chatContent(meta['chat']['contents'], meta['chat']['type']);
        //   int userId = Constants.user.id;
        //   int gChat = gChatRoomUid;
        //   if (meta["chat"]["sender_id"] == Constants.user.id ||
        //       (title ?? "") == "my_chat" ||
        //       meta["chat"]["type"] == 5 || (title ?? "") == "Leave") {
        //     return;
        //   }
        // }
      }

       if (message.data != null) {
        if (meta['fcmType'] != 10) { //채팅이 아닐때
          flutterLocalNotificationsPlugin.show(
              message.hashCode,
              title,
              contentBody,
              NotificationDetails(
                  android: AndroidNotificationDetails(
                    channel.id,
                    channel.name,
                    priority: Priority.high,
                    importance: Importance.high,
                    channelDescription: channel.description,
                    // icons: message.notification?.android?.smallIcon,
                    playSound: true,
                  ),
                  iOS: DarwinNotificationDetails(
                      presentAlert: true,
                      presentBadge: true,
                      presentSound: true)),
              payload: jsonEncode(message.data));
        } else { // 채팅일 때
          flutterLocalNotificationsPlugin.show(
              meta['room']['id'],
              title,
              contentBody,
              NotificationDetails(
                  android: AndroidNotificationDetails(
                    channel.id,
                    channel.name,
                    priority: Priority.high,
                    importance: Importance.high,
                    channelDescription: channel.description,
               //     tag:(message.data['meta']['room_id']).toString(),
                    // icons: message.notification?.android?.smallIcon,
                    playSound: true,
                  ),
                  iOS: DarwinNotificationDetails(
                      presentAlert: true,
                      presentBadge: true,
                      presentSound: true)),
              payload: jsonEncode(message.data));
        }
      }
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

    //   DioClient.getChatRoom(chatRoomId).then((response) {
    //     ChatRoomDto room = ChatRoomDto.fromJson(response.data);
    //     Get.to(ChatDetailPage(
    //       roomDto: room,
    //       roomRefresh: (room) {},
    //       changeRoom: (room) {},
    //       onDeleteRoom: (room) {},
    //     ));
    //   });
    // } else if (fcmType == 4) {
    //   // 내 포스트에 댓글 및 대댓글
    //   // link += "?commentId=${data['value']}";
    //   print("푸쉬 링크 ${link}");
    //   Utils.urlLaunch(link);
    // } else if (fcmType == 3) {
    //   // 포스팅 좋아요
    //   String postId = data['value'];
    //   DioClient.getPost(postId).then((response) {
    //     Get.to(PostDetailScreen(post: PostModel.fromJson(response.data)));
    //   });
    // } else if (fcmType == 5) {
    //   //포스팅 댓글 좋아요
    //   link += "?commentId=${data['value']}";
    //   print("푸쉬 링크 ${link}");
    //   Utils.urlLaunch(link);
    // } else if (fcmType == 8) {
    //   // 유저 팔로우
    //   Utils.urlLaunch(link);
    // } else if (fcmType == 16) {
    //   // 게임 팔로우
    //   Utils.urlLaunch(link);
    // }
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
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      // WriteLog.write("fcm come time:  ${DateTime.now()}\n message : ${message} \n  ",fileName: 'fcmCome.txt');

      //RemoteNotification? notification = message!.notification;
   
      //String body = notification?.body ?? '';
      if(message ==null)
      {
        return;
      }

      String contentBody="" ;
      final meta = jsonDecode(message.data['meta']) ?? "";
      String title = (message.data['title']) ?? ""; // data 의 title
       int fcmType = meta['fcmType'];
        
        if(fcmType==0 && title=='expire-chat')
        {
          final dataBody = jsonDecode(message.data['body']) ?? "";
          if(dataBody['first_chat_id'] ==-1) {
            //flutterLocalNotificationsPlugin.cancelAll();
            flutterLocalNotificationsPlugin.cancel(dataBody['room_id'],); // 플러그인의 함수에서 만약 없는 푸시를 삭제한다고 해도 예외처리가 되어있음을 확인했음
          }
          return;
        }
        else
        {
        contentBody =  (message.data['body']) ?? "";
        }
      // Map<String, dynamic> notification;      
      // notification={
      //     "title": title,
      //     "body": contentBody,
      // };
      // RemoteMessage notificationRm = RemoteMessage.fromMap(notification);

      // Map<String,dynamic> fcmData;
      // fcmData={
      //   "notification" : notificationRm,
      //   "data" : message.data
      // };
      // RemoteMessage msg = RemoteMessage.fromMap(fcmData);

      
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
      if (message.data != null) {
        if (jsonDecode(message.data['meta'])['fcmType'] != 10) { //채팅이 아닐때
          flutterLocalNotificationsPlugin.show(
              message.hashCode,
              title,
              contentBody,
              NotificationDetails(
                  android: AndroidNotificationDetails(
                    channel.id,
                    channel.name,
                    priority: Priority.high,
                    importance: Importance.high,
                    channelDescription: channel.description,                    
                    // icons: message.notification?.android?.smallIcon,
                    playSound: true,
                  ),
                  iOS: DarwinNotificationDetails(
                      presentAlert: true,
                      presentBadge: true,
                      presentSound: true)),
              payload: jsonEncode(message.data));
        } else { // 채팅일 때
          flutterLocalNotificationsPlugin.show(
              meta['room']['id'],
              title,
              contentBody,
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
