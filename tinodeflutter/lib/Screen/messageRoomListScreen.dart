import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tinodeflutter/Constants/ColorConstants.dart';
import 'package:tinodeflutter/Constants/Constants.dart';
import 'package:tinodeflutter/Constants/FontConstants.dart';
import 'package:tinodeflutter/Constants/ImageConstants.dart';
import 'package:tinodeflutter/Constants/utils.dart';
import 'package:tinodeflutter/InAppPurchase/purchaseScreen.dart';
import 'package:tinodeflutter/Screen/BottomNavBarScreen.dart';
import 'package:tinodeflutter/Screen/FriendListScreen.dart';
import 'package:tinodeflutter/Screen/ProfileScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'package:tinodeflutter/Screen/SearchUser.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:http/http.dart';
import 'package:tinodeflutter/components/item/item_chat_room.dart';
import 'package:tinodeflutter/components/widget/BtnBottomSheetWidget.dart';
import 'package:tinodeflutter/components/widget/EditRoomNameBottomSheet.dart';
import 'package:tinodeflutter/components/widget/dialog.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:tinodeflutter/model/MessageRoomModel.dart';
import 'package:tinodeflutter/model/MessageRoomModel.dart';
import 'package:tinodeflutter/model/btn_bottom_sheet_model.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/page/base/base_state.dart';
import 'package:tinodeflutter/page/base/page_layout.dart';

import '../components/item/PositionRetainedScrollPhysics.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_it/get_it.dart';

import '../global/global.dart';
import '../tinode/tinode.dart';
import 'messageRoomAddScreen.dart';
import 'messageRoomScreen.dart';

class MessageRoomListScreen extends StatefulWidget {
  MessageRoomListScreen({super.key, required this.messageListScreenInitController});
  InitController messageListScreenInitController;
  @override
  State<MessageRoomListScreen> createState() => _MessageRoomListScreenState(messageListScreenInitController);
}

class _MessageRoomListScreenState extends BaseState<MessageRoomListScreen> {

   _MessageRoomListScreenState(InitController _messageRoomListScreenController){
    _messageRoomListScreenController.initHome = initHome;
  }
  //late Topic roomTopic;
  late Topic me;
  AutoScrollController mainController = AutoScrollController();
  TextEditingController inputController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  PositionRetainedScrollPhysics physics = PositionRetainedScrollPhysics();
  List<TopicSubscription> roomList = [];
  late TopicDescription topicDescription;

  List<MessageRoomModel> roomAllList = [];
  List<MessageRoomModel> tempRoomList = [];
  List<MessageRoomModel> roomFilterList = [];
  bool isInit = false;

  void onDelete(int index) {}

 //ScrollController scrollController = ScrollController();

  void initHome() {
    mainController.jumpTo(0);
  }
  @override
  void pingListen() {
    // TODO: implement pingListen
    super.pingListen();
  }
  @override
  void initState() {
    super.initState();
    me = tinode_global.getMeTopic();
    _setupListeners();
    // pingListen();
  //  _initializeTopic();
    // getMsgRoomList();
  }
  @override
  void dispose() {
    // pingSubscription.cancel();
    super.dispose();
  }
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    return super.didChangeAppLifecycleState(state);
  }

   void _initializeTopic() async {
    me = tinode_global.getMeTopic();
    var result = await me.subscribe(MetaGetBuilder(me).withLaterSub(null).build(), null);
    //_loadRooms();
    _setupListeners();
  }

  void _loadRooms() {
    var subs = me.subscribers;
    setState(() {
      roomList = subs.values.toList();
       roomList.sort((a, b) => b.touched!.compareTo(a.touched!));
    });
  }
  
  int count = 0;
  int compareRoomList(TopicSubscription a, TopicSubscription b)
  {
    
    if(a.public?['fn'] == null)
    {
       Map<String,dynamic> publicData = {
        'fn' : "New Room",
        'description' :"New  Room"
      };
      a.public = publicData;
    }
    if(b.public?['fn'] == null)
    {
      Map<String,dynamic> publicData = {
        'fn' : "New Room",
        'description' :"New Room"
      };
      b.public = publicData;
    }
    if(a.touched ==null)
    {
      a.touched= DateTime.now();
    }
    if(b.touched ==null)
    {
      b.touched= DateTime.now();
    }
    print("${a.topic} : ${a.touched} , ${b.topic} : ${b.touched}     count : ${count++}   , a fn : ${a.public?['fn']?? "null"} , b fn : ${b.public?['fn']??"null"}");
    return b.touched!.compareTo(a.touched!);    
  }

  void _setupListeners() async{
    try{
    me.onSubsUpdated.listen((value) {
      print("Subs updated: $value");
      count = 0; 
      setState(() {
        //roomList = value;
        value.forEach((item){
          try{
            bool hasPublic=true;
          if(item.public ==null) hasPublic=false;
          UserModel p2pUserData = item.topic?[0] == 'u' ? UserModel(id: item.topic ?? '', 
            name: hasPublic? (item.public['fn'] ?? "") : "", 
            picture: hasPublic? (item.public['photo']!=null ? (item.public['photo']['ref']!=null ? (item.public['photo']['ref'] ?? "" ) : (item.public['photo'] ?? "")):""): "", 
            isFreind: item.isFriend ?? false) 
            : UserModel(id: "", name: "", picture: "", isFreind: false);
            
          MessageRoomModel messageRoomModel = 
            MessageRoomModel(id: item.topic??"",
            name: hasPublic ? (item.public['fn']?? "") : "",
             created_at: item.created.toString() ?? "",  
             updated_at: item.updated.toString() ?? "",  
             deleted_at: item.deleted.toString() ?? "",  
             touched_at: item.touched.toString() ?? "",  
            is_group_room: item.topic?[0] == 'g' , 
            is_my_room: item.topic == tinode_global.userId,
            read : item.read??0,
            recv : item.recv ?? 0,
            seq : item.seq??0,
            userList: [p2pUserData],
            unread_count: item.unread ?? 0);
            tempRoomList.add(messageRoomModel);
          }
          catch(err)
          {
            print("err");
          }
        
        });

        roomFilterList = tempRoomList.reversed.toList();
        tempRoomList.clear();
        // roomFilterList = roomAllList.reversed.toList();
        //roomList.sort(compareRoomList);
      });
    });

    me.onPres.listen((value) async{
      print("Presence value: $value");
      String topic = value.src ?? "";
      int seq = value.seq ?? -1;
      String sender = value.act?? "";
      bool isExistRoom = roomList.any((subscription) => subscription.topic!. contains(topic));
      switch(value.what)
      {
        case 'msg':
         
        break;
        case 'acs': // 방 생성
          Topic roomTopic = tinode_global.getTopic(topic);
         if(!roomTopic.isSubscribed)
         {
          await roomTopic.subscribe(MetaGetBuilder(roomTopic).withData(null, null, null).withSub(null, null, null).withDesc(null).build(), null);
          TopicSubscription topicSubscription = TopicSubscription(topic: roomTopic.name, acs: roomTopic.acs, public: roomTopic.public, seq: roomTopic.maxSeq,created: roomTopic.created, updated: roomTopic.updated, touched: roomTopic.touched );
          roomList.insert(0,topicSubscription);
          
          setState(() {
            
             roomList.sort(compareRoomList);
          });
         }
          
        break;

        case 'on':
        return;

        default:
        break;
      }
      print("ddd");

      // if(isExistRoom)
      // {
      //   //update
      // }
      // else if(src != "") //새로운 방
      // {
      //   TopicSubscription topicSubscription = TopicSubscription(topic: src, seq: seq, );
      //   roomList.add(topicSubscription);
      //   setState(() {
          
      //   });
      // }

    });
     GetQuery getQuery = GetQuery(
      what: 'sub',
    );
    var meta = await me.getMeta(getQuery);
    print("ee");
    //await me.subscribe(MetaGetBuilder(me).withSub(null,null,null).build(), null);

    //getMyInfo();
    }
    catch(err)
    {
      print("err");
    }
    
  }

  Future<void> getMyInfo() async
  {
    //내 data 받아오기
    GetQuery getQuery = GetQuery(
      what: 'sub desc tags cred membership',
    );
    GetQuery getMembershipQuery = GetQuery(
      what: 'membership',
    );
    // fnd 토픽에 메타데이터 요청 보내기
    var meta = await me.getMeta(getQuery);
    var membershipMeta = await me.getMeta(getMembershipQuery);

    var userId = tinode_global.getCurrentUserId();
    String pictureUrl = meta.desc?.public['photo']?['ref'] != null ? changePathToLink(meta.desc?.public['photo']['ref']) : "";
    Constants.user = UserModel(id: userId, name: meta.desc.public['fn'], membership: membershipMeta.membership, picture: pictureUrl, isFreind: false);

  }


  Future<void> getMsgRoomList() async {
    // me = tinode_global.getMeTopic();
    try {
      // me.onSubsUpdated.listen((value) {
      //   // for (var item in value) {
      //   //   print('Subscription[' +
      //   //       item.topic.toString() +
      //   //       ']: ' +
      //   //       item.public['fn'] +
      //   //       ' - Unread Messages:' +
      //   //       item.unread.toString());
      //   // }

      //   setState(() {
      //   roomList = value;
      //    roomList.sort((a, b) => b.updated!.compareTo(a.updated!));
      //   });
        
      //   print("room List : ${roomList.length}");
      // });

      // me.onData.listen((data) {
      //   // 필요한 경우 데이터를 처리할 수 있습니다.
      //   print("Data received: $data");
      // });
      var result = await me.subscribe(MetaGetBuilder(me).withLaterSub(null).build(), null);
    } catch (err) {
      print("err : $err");
    }
  }


  String clickTopic = "";
  void onClickMsgRoom(String clickTopic) {
    this.clickTopic = clickTopic;
    Get.to(()=>MessageRoomScreen(
  
      clickTopic: this.clickTopic,
    ));
  }

    Future<void> refresh() async {
    // setState(() {
    //   roomAllList.clear();
    //   roomFilterList.clear();
    // });
    // nextPage = 0;
    // await ChatRoomUtils.deleteAllRooms();
    // getRoomList();
  }

  Widget _searchWidget()
  {
    return  Container(
                height: 65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4)
                ),
                padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),
                      color: ColorConstants.white
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(ImageConstants.chatSearchWhite, height: 24, width: 24, color: Colors.grey,),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          cursorColor: Colors.black,
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                              fontFamily: FontConstants.AppFont,
                              fontSize: 14,
                          ),
                          onEditingComplete: () => {},
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                              counterText: "",
                              contentPadding: EdgeInsets.zero,
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              hintText: '채팅방 검색',
                              isDense: true,
                              hintStyle: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: FontConstants.AppFont,
                                  color: Colors.grey,
                                  fontSize: 14
                              ),
                              border: InputBorder.none),
                          onChanged: (text) {
                            // setState(() {
                            //   setFilteringList();
                            // });
                          },
                        ),
                      )
                    ],
                  ),
                ),
              );
  }

  Widget _messageRoomListWidget()
  {
    return Expanded(
                child: Container(
                  color: ColorConstants.white,
                  child: Stack(
                    children: [

                      Visibility(
                        visible: roomFilterList.isEmpty,
                          child: Center(
                            child: AppText(
                              text: "empty_room_list".tr(),
                              fontSize: 13,
                              color: ColorConstants.textGry,
                            ),
                          )
                      ),

                      Visibility(
                        visible: roomFilterList.isNotEmpty,
                        child: RefreshIndicator(
                          onRefresh: refresh,
                          color: ColorConstants.colorMain,
                          child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              controller: mainController,
                              itemBuilder: (BuildContext context, int index) {
                                return ItemChatRoom(
                                  info: roomFilterList[index],
                                  onClick: () {
                                    onClickMsgRoom(roomFilterList[index].id.toString());
                                  },
                                  onLongPress: () {
                                    MessageRoomModel roomModel = roomFilterList[index];
                                    List<BtnBottomSheetModel> items = [];
                                    if((roomModel.userList?.length ?? 0) >= 1)
                                      items.add(BtnBottomSheetModel(ImageConstants.addChatUserIcon, "add_room_member".tr(), 0));
                                    if((roomModel.userList?.length ?? 0) >= 1)
                                      items.add(BtnBottomSheetModel(ImageConstants.editRoomIcon, "change_room_name".tr(), 1));
                                    if((roomModel.userList?.length ?? 0) == 1)
                                      items.add(BtnBottomSheetModel(ImageConstants.banUserIcon, "user_block".tr(), 2));
                                    if((roomModel.userList?.length ?? 0) == 1)
                                      items.add(BtnBottomSheetModel(ImageConstants.reportUserIcon, "report_title".tr(), 3));
                                    items.add(BtnBottomSheetModel(ImageConstants.exitRoomIcon, "chat_leave".tr(), 4));
                                    Get.bottomSheet(enterBottomSheetDuration: Duration(milliseconds: 100), exitBottomSheetDuration: Duration(milliseconds: 100),BtnBottomSheetWidget(
                                      btnItems: items,
                                      onTapItem: (menuIndex) async {
                                        if(menuIndex == 0){
                                          Navigator.of(context).push(
                                              SwipeablePageRoute(
                                                  canOnlySwipeFromEdge: true,
                                                  builder: (context) => MessageRoomAddScreen(
                                                      existUserList: roomModel.userList ?? [],
                                                      // roomIdx: roomModel.id,
                                                      // room: roomModel,
                                                      // refresh: (){
                                                      //   getRoomList();
                                                      // },changeRoom: (room){
                                                      // openChatDetailPage(room);
                                                      // },
                                                    )
                                                  )
                                                  )
                                              .then((value) {

                                          });
                                        }else if(menuIndex == 1){
                                          Get.bottomSheet(enterBottomSheetDuration: Duration(milliseconds: 100), exitBottomSheetDuration: Duration(milliseconds: 100),EditRoomNameBottomSheet(
                                            roomModel: roomModel,
                                            inputName: (name) async {
                                              if (name.isEmpty) {
                                                return;
                                              }
                                              Map<String, dynamic> body = {
                                                "name": name,
                                                "room_id": roomModel.id,
                                              };
                                              showLoading();
                                              // apiC
                                              //     .changeRoomName("Bearer ${await FirebaseAuth
                                              //     .instance.currentUser?.getIdToken()}",
                                              // jsonEncode(body))
                                              //     .then((value) {
                                              //   hideLoading();
                                              //   setState(() {
                                              //     List<MessageRoomModel> list = roomAllList.where((element) => element.id == roomModel.id).toList();
                                              //     if (list.isNotEmpty) {
                                              //       int index = roomAllList.indexOf(list.first);
                                              //       MessageRoomModel item = roomAllList[index];
                                              //       item.name = name;
                                              //       item.has_name = true;
                                              //       roomAllList.removeAt(index);
                                              //       roomAllList.insert(index, item);
                                              //       ChatRoomUtils.saveChatRoom(item);
                                              //     }

                                              //     List<MessageRoomModel> list1 = roomFilterList.where((element) => element.id == roomModel.id).toList();
                                              //     if (list1.isNotEmpty) {
                                              //       int index = roomFilterList.indexOf(list1.first);
                                              //       MessageRoomModel item = roomFilterList[index];
                                              //       item.name = name;
                                              //       item.has_name = true;
                                              //       roomFilterList.removeAt(index);
                                              //       roomFilterList.insert(index, item);
                                              //     }
                                              //   });
                                              // }).catchError((Object obj) {
                                              //   hideLoading();
                                              //   showToast("connection_failed".tr());
                                              // });
                                            },
                                          ));
                                        }else if(menuIndex == 2){
                                          List<UserModel> users = roomFilterList[index].userList ?? [];
                                          for(int i=0;i<users.length;i++){
                                            if(users[i].id != Constants.user.id){
                                              // var response = await DioClient.postUserBlock(users[i].id);
                                              Utils.showToast("ban_complete".tr());
                                              break;
                                            }
                                          }
                                        }
                                        // else if(menuIndex == 3){
                                        //   List<UserModel> users = roomFilterList[index].userList ?? [];
                                        //   for(int i=0;i<users.length;i++){
                                        //     if(users[i].id != Constants.user.id){
                                        //       showModalBottomSheet<dynamic>(
                                        //           isScrollControlled: true,
                                        //           context: context,
                                        //           useRootNavigator: true,
                                        //           backgroundColor: Colors.transparent,
                                        //           builder: (BuildContext bc) {
                                        //             return ReportUserDialog(onConfirm: (reportList, reason) async {
                                        //             //  var response = await DioClient.reportUser(users[i].id, reportList, reason);
                                        //               Utils.showToast("report_complete".tr());
                                        //             },);
                                        //           }
                                        //       );
                                        //       break;
                                        //     }
                                        //   }
                                        // }
                                        else {
                                          AppDialog.showConfirmDialog(context, "leave_title".tr(), "leave_content".tr(), () {
                                            //chatRoomLeave(roomModel);
                                          });
                                        }
                                      },
                                    ));
                                  },
                                  onDelete: () {
                                    onDelete(index);
                                  },
                                );
                              },
                              itemCount: roomFilterList.length),
                        ),
                      ),
                    ],
                  ),
                ),
              );
  }

  Widget _topBarWidget()
  {
    return  Container(
            height: 56, // AppBar의 기본 높이
            child: Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: AppText(
                      text: "JadeChat",
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        Get.to(MessageRoomAddScreen());
                        // Navigator.of(context).push(
                        //   SwipeablePageRoute(
                        //     canOnlySwipeFromEdge: true,
                        //     builder: (context) => MessageRoomAddScreen(),
                        //   ),
                        // ).then((value) {});
                      },
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Icon(
                          Icons.add_circle_outline,
                          size: 25,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
           
  }


  

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: ColorConstants.backgroundGrey, // 원하는 색상으로 변경
      statusBarBrightness: Brightness.light, // iOS에서 상태바 콘텐츠를 어둡게 (검은색)
      statusBarIconBrightness: Brightness.dark, 
    ));
    return PageLayout(
        //onBack: onBackPressed,
        isLoading: isLoading,
        child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(children: [
          SizedBox(height: Get.height * 0.04),
          Obx(() => AppText(text: "ping: ${base_pingMiliSeconds.value}ms")),

          // SizedBox(height: Get.height * 0.07),
         _topBarWidget(),
          _searchWidget(),

          SizedBox(
            height: 10,
          ),
      
          _messageRoomListWidget(),
          SizedBox(height: Constants.navBarHeight,),
          // Expanded(
          //   child: ListView.builder(
          //       cacheExtent: double.infinity,
          //       shrinkWrap: false,
          //       padding: const EdgeInsets.all(10),
          //       controller: mainController,
          //       itemCount: roomList.length,
          //       reverse: false,
          //       physics: physics,
          //       itemBuilder: (BuildContext context, int index) {
          //         return AutoScrollTag(
          //           key: ValueKey(index),
          //           controller: mainController,
          //           index: index,
          //           child: GestureDetector(
          //               onLongPress: () => {},
          //               child: Stack(
          //                 children: [
                            
          //                     InkWell(
          //                       onTap: () {
          //                         onClickMsgRoom(
          //                             roomList[index].topic.toString());
          //                       },
          //                       child: Container(
          //                         height: 40,
          //                         child: Row(children: [
          //                           AppText(
          //                             text: roomList[index].public !=null ? roomList[index].public['fn'] : (roomList[index].topic ?? "혼자인 방"),
          //                             fontSize: 12,
          //                             color: Colors.black,
          //                           ),
          //                           SizedBox(
          //                             width: 10,
          //                           ),
          //                           if (roomList[index].touched != null)
          //                             AppText(
          //                               text: (roomList[index]
          //                                   .touched
          //                                   .toString()),
          //                               fontSize: 12,
          //                               color: Colors.black,
          //                             ),
          //                           SizedBox(
          //                             width: 10,
          //                           ),
          //                            if (roomList[index].unread != null && roomList[index].unread != 0) ...[
          //                           AppText(
          //                             text: roomList[index].unread.toString(),
          //                             fontSize: 12,
          //                             color: Colors.red,
          //                           ),]
          //                         ]),
          //                       ),
          //                     ),
          //                 ],
          //               )),
          //         );
          //       }),
          // ),
        ]),
      ),
    );
  }
}
