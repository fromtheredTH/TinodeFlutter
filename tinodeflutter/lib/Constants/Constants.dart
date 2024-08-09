import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:android_id/android_id.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinodeflutter/InAppPurchase/purchaseScreen.dart';
import 'package:tinodeflutter/Screen/BottomNavBarScreen.dart';
import 'package:tinodeflutter/global/DioClient.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/tinode/src/meta-get-builder.dart';
import 'package:tinodeflutter/tinode/src/models/get-query.dart';
import 'package:tinodeflutter/tinode/src/models/topic-subscription.dart';
import 'package:tinodeflutter/tinode/src/topic.dart';


import 'ImageConstants.dart';

class Constants {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Uint8List? userQrCode;
  static String userQrUrl = "jade-chat.com/";
  static String languageCode = "";
  static String translationCode = "";
  static String translationName = "";
  static String cachingKey = "";
  static late UserModel user;

  static late TopicSubscription mytopicSubscription;

  static double navBarIconSize = Get.width * 0.07;
  static double navBarHeight = Get.width * 0.155;

  static List<String> reportUserLists = [
    "report_user_1".tr(),
    "report_user_2".tr(),
    "report_user_3".tr(),
    "report_user_4".tr(),
    "report_user_5".tr()
  ];

  static List<String> reportLists = [
    "report_1".tr(),
    "report_2".tr(),
    "report_3".tr(),
    "report_4".tr(),
    "report_5".tr(),
    "report_6".tr(),
  ];

  static String versionName = "";

  static Future<void> initSetting() async
  {
    try{
    Topic me = tinode_global.getMeTopic();
    await setMyTopicSubscribe(me);
    await getMyInfo(me);
    PurchaseScreen.instance.initPurchaseState(); // purchase item init
    gCurrentId = Constants.user.id;
    Get.offAll(BottomNavBarScreen(),transition: Transition.rightToLeft);
  
    }
    catch(err)
    {
      print("constants err : $err");
    }
    }


  static Future<void> setMyTopicSubscribe(Topic me) async{
    try{
      await me.subscribe(MetaGetBuilder(me).build(), null);
    }
    catch(err)
    {
      print("err");
    }
    
  }

  static Future<void> getMyInfo(Topic me) async
  {
    try{

    //내 data 받아오기
    GetQuery getQuery = GetQuery(
      what: 'sub desc cred',
    );
    GetQuery getMembershipQuery = GetQuery(
      what: 'membership',
    );
    GetQuery getTagsQuery = GetQuery(
      what: 'tags',
    );
    // fnd 토픽에 메타데이터 요청 보내기
    var meta = await me.getMeta(getQuery);
    var membershipMeta = await me.getMeta(getMembershipQuery);
    var tagData = await me.getMeta(getTagsQuery);

    var userId = tinode_global.getCurrentUserId();
    String pictureUrl = meta.desc?.public['photo']?['ref'] != null ? changePathToLink(meta.desc?.public['photo']['ref']) : "";
    String searchId = tagData.tags.last.replaceFirst("search:", "");
    Constants.user = UserModel(id: userId, name: meta.desc.public['fn'], membership: membershipMeta.membership, picture: pictureUrl,searchId: searchId, tags: tagData.tags, isFreind: false);

    }
    catch(err)
    {
      print("myinfo err : $err");
    }
  }




  // static String getNameList(List<MatchEnumModel> items) {
  //   String result = "";
  //   if (items.isNotEmpty) {
  //     result =
  //         Constants.languageCode == "ko" ? items[0].koName : items[0].enName;
  //   }

  //   for (int i = 1; i < items.length; i++) {
  //     result +=
  //         ", ${Constants.languageCode == "ko" ? items[i].koName : items[i].enName}";
  //   }
  //   return result;
  // }




  // static Future<void> fetchChatRooms() async {
  //   Constants.localChatRooms = await ChatRoomUtils.getChatRooms();

  //   int maxId = -1;
  //   for (int i = 0; i < Constants.localChatRooms.length; i++) {
  //     if (Constants.localChatRooms[i].last_chat_id > maxId) {
  //       maxId = Constants.localChatRooms[i].last_chat_id;
  //     }
  //   }
  //   if (maxId != -1) {
  //     var response = await DioClient.getChatUpdate(maxId);
  //     List<ChatRoomDto> newRooms = response.data["result"]["new_rooms"]
  //         .map((json) => ChatRoomDto.fromJson(json))
  //         .toList()
  //         .cast<ChatRoomDto>();
  //     List<ChatRoomDto> deletedRooms = response.data["result"]["deleted_rooms"]
  //         .map((json) => ChatRoomDto.fromJson(json))
  //         .toList()
  //         .cast<ChatRoomDto>();
  //     int nextPage = 0;

  //     await ChatRoomUtils.saveMultiChatRoom(newRooms);
  //     await ChatRoomUtils.saveMultiChatRoom(deletedRooms);

  //     var firstMessageData = await DioClient.getFirstMessageData(20, nextPage);
  //     print("first message ${firstMessageData.data['result']}");
  //     for (int i = 0; i < firstMessageData.data["result"].length; i++) {
  //       for (int j = 0; j < Constants.localChatRooms.length; j++) {
  //         if (Constants.localChatRooms[j].id ==
  //             firstMessageData.data["result"][i]['room_id']) {
  //           Constants.localChatMsgList =
  //               await ChatUtils.getChats(Constants.localChatRooms[j].id);
  //           // for (int t = 0; t < Constants.localChatMsgList.length; t++) {
  //           //   print(
  //           //       "room id : ${Constants.localChatMsgList[t].room_id} localChatMsgList[k].id : ${Constants.localChatMsgList[t].id}");
  //           // }

  //           for (int k = 0; k < Constants.localChatMsgList.length; k++) {
  //                if(firstMessageData.data['result'][i]['first_chat_id']==-1)
  //                {
  //                   print("first chat idx =-1  all delete");
  //                   if(Constants.localChatMsgList[k].type ==5) {continue;}
  //                   else {
  //                     await ChatUtils.deleteChatFromId(
  //                   Constants.localChatMsgList[k].room_id,
  //                   localChatMsgList[k].id);
  //                   }
  //                   //ChatUtils.deleteAllChats(Constants.localChatMsgList[k].room_id);
  //                   //break;
  //                }
  //             else if (firstMessageData.data["result"][i]['first_chat_id'] > Constants.localChatMsgList[k].id) {
  //               print("localChatMsgList[k].id : ${localChatMsgList[k].id}");
  //               print(
  //                   "firstMessageData.data ['first_chat_id'] : ${firstMessageData.data["result"][i]['first_chat_id']}");
  //               if(Constants.localChatMsgList[k].type ==5) {continue;}
  //               await ChatUtils.deleteChatFromId(
  //                   Constants.localChatMsgList[k].room_id,
  //                   localChatMsgList[k].id);
  //             }
  //           }
  //         }
  //       }
  //     }

      
  //     Constants.localChatRooms = await ChatRoomUtils.getChatRooms();
  //     print(response);
  //   } else {
  //     bool hasNextPage = true;
  //     int nextPage = 0;
  //     while (hasNextPage) {
  //       var response = await DioClient.getChatRoomList(20, nextPage);
  //       final value = ChatRoomResModel.fromJson(response.data!);
  //       await ChatRoomUtils.saveMultiChatRoom(value.result);
  //       Constants.localChatRooms = await ChatRoomUtils.getChatRooms();
  //       hasNextPage = value.pageInfo?.hasNextPage ?? false;
  //       nextPage += 1;
  //     }
  //   }
  // }

  // static Future<void> getUserInfo(
  //     bool isShowLoading, BuildContext context, ApiP apiP) async {
  //   if (isShowLoading) Utils.showDialogWidget(context);

  //   DioClient.getMyInfo().then((value) async {
  //     Constants.user = UserModel.fromJson(value.data["result"]["user"]);
  //     //  initPosts();
  //     //  initBgList();
  //     //  initDiscoverPosts();
  //     // initCommunities();
  //     // initCountryModels();
  //     getQrCode();
  //     getVersionInfo();
  //    // initNotificationLists();
  //     getTranslateCodeList();
  //     gCurrentId = Constants.user.id;
  //     PurchaseScreen.instance.initPurchaseState();

  //     initUserSubDatas();
  //     await Constants.fetchChatRooms();
  //     print("here 3");

  //     FirebaseAuth.instance.currentUser?.getIdToken().then((value) {
  //       String token = "Bearer ${value}";
  //       initFcm(token);
  //     });
  //     Get.put(CallService());

  //     // Get.offAll(ChatPage(),transition: Transition.rightToLeft);

  //     // Get.back();
  //     Get.offAll(BottomNavBarScreen(), transition: Transition.rightToLeft);
  //   }).catchError((Object obj) {
  //     showToast("connection_failed".tr());
  //     if (isShowLoading) Get.back();
  //   });
  // }

  // static void initUserSubDatas() async {
  //   bool hasFollowerNext = true;
  //   int followerPage = 0;
  //   while (hasFollowerNext) {
  //     var followerRseponse =
  //         await DioClient.getUserFollowings(user.id, 100, followerPage);
  //     List<UserModel> followers = followerRseponse.data["result"] == null
  //         ? []
  //         : followerRseponse.data["result"]
  //             .map((json) => UserModel.fromJson(json))
  //             .toList()
  //             .cast<UserModel>();
  //     followerPage += 1;
  //     hasFollowerNext =
  //         followerRseponse.data["pageInfo"]?["hasNextPage"] ?? false;
  //     for (int i = 0; i < followers.length; i++) {
  //       if (followers[i].nickname.isEmpty) {
  //         followers.removeAt(i);
  //         i--;
  //       }
  //     }
  //     myFollowings.addAll(followers);
  //   }


  // }

  // static Future<void> initFcm(String token) async {
  //   String device_id = "";
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  //   if (Platform.isAndroid) {
  //     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //     device_id = androidInfo.id;
  //     const _androidIdPlugin = AndroidId();
  //     device_id = await _androidIdPlugin.getId() ?? '';
  //   } else if (Platform.isIOS) {
  //     IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  //     device_id = iosInfo.identifierForVendor ?? '';
  //   }
  //   FirebaseMessaging.instance.getToken().then((token) {
  //     print('token:' + (token ?? ''));
  //     LocalService.setToken((token ?? ''));
  //     gPushKey = (token ?? '');
  //     var response = DioClient.setFCM(gPushKey, device_id);
  //   });
  // }



  static Future<void> getVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    versionName = packageInfo.version;
  }




  static Future<void> getQrCode() async {
    var response = await DioClient.getUserQR();
    print(response);
    String data = response.data["result"]["qr"];
    userQrCode = Base64Decoder().convert(data);
  }


  // static int getUnreadMsg() {
  //   int unRead = 0;
  //   for (ChatRoomDto dto in Constants.localChatRooms) {
  //     unRead += dto.unread_count;
  //   }

  //   return unRead;
  // }
}
