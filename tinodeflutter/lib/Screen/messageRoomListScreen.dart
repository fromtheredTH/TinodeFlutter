import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tinodeflutter/Constants/Constants.dart';
import 'package:tinodeflutter/Screen/FriendListScreen.dart';
import 'package:tinodeflutter/Screen/ProfileScreen.dart';

import 'package:tinodeflutter/Screen/SearchUser.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:http/http.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:tinodeflutter/model/userModel.dart';

import '../components/item/PositionRetainedScrollPhysics.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_it/get_it.dart';

import '../global/global.dart';
import '../tinode/tinode.dart';
import 'messageRoomAddScreen.dart';
import 'messageRoomScreen.dart';

class MessageRoomListScreen extends StatefulWidget {
  Tinode tinode;
  MessageRoomListScreen({super.key, required this.tinode});

  @override
  State<MessageRoomListScreen> createState() => _MessageRoomListScreenState();
}

class _MessageRoomListScreenState extends State<MessageRoomListScreen> {
  late Tinode tinode;
  //late Topic roomTopic;
  late Topic me;
  AutoScrollController mainController = AutoScrollController();
  TextEditingController inputController = TextEditingController();
  PositionRetainedScrollPhysics physics = PositionRetainedScrollPhysics();
  List<TopicSubscription> roomList = [];
  late TopicDescription topicDescription;

  @override
  void initState() {
    super.initState();
    tinode = widget.tinode;
    me = widget.tinode.getMeTopic();
    _setupListeners();
  //  _initializeTopic();
    // getMsgRoomList();
  }

   void _initializeTopic() async {
    me = tinode.getMeTopic();
    var result = await me.subscribe(MetaGetBuilder(me).withLaterSub(null).build(), null);
    _loadRooms();
    _setupListeners();
  }

  void _loadRooms() {
    var subs = me.subscribers;
    setState(() {
      roomList = subs.values.toList();
       roomList.sort((a, b) => b.updated!.compareTo(a.updated!));
    });
  }
  
  void _setupListeners() async{

    me.onSubsUpdated.listen((value) {
      print("Subs updated: $value");
      setState(() {
        roomList = value;
        roomList.sort((a, b) => b.updated!.compareTo(a.updated!));
      });
    });

    me.onPres.listen((event) {
      print("Presence event: $event");
      if (event.what == 'acs') {
       // getMsgRoomList();
       print("come acs");
      }
    });
    
    await me.subscribe(MetaGetBuilder(me).withLaterSub(null).build(), null);

    getMyInfo();
  }

  Future<void> getMyInfo() async
  {
    //내 data 받아오기
    GetQuery getQuery = GetQuery(
      what: 'sub desc tags cred membership',
    );
    // fnd 토픽에 메타데이터 요청 보내기
    var meta = await me.getMeta(getQuery);
    var userId = tinode.getCurrentUserId();
    String pictureUrl = meta.desc?.public['photo']?['ref'] != null ? changePathToLink(meta.desc?.public['photo']['ref']) : "";
    Constants.user = User(id: userId, name: meta.desc.public['fn'], picture: pictureUrl, isFreind: false);
  }


  Future<void> getMsgRoomList() async {
    // me = tinode.getMeTopic();
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
      tinode: tinode,
      clickTopic: this.clickTopic,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("방 리스트"),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(children: [
          Row(
            children: [
              InkWell(
                onTap: () => {Get.to(SerachUserScreen(tinode: tinode))},
                child: Container(
                  width: 80,
                  height: 50,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 2.0,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(4))),
                  child: AppText(
                    text: "유저검색",
                    color: Colors.black,
                  ),
                ),
              ),
           
              InkWell(
                onTap: () => {Get.to(MessageRoomAddScreen(tinode: tinode))},
                child: Container(
                  width: 80,
                  height: 50,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 2.0,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(4))),
                  child: AppText(
                    text: "방 만들기",
                    color: Colors.black,
                  ),
                ),
              ),
              InkWell(
                onTap: () => {Get.to(ProfileScreen(tinode: tinode, user: Constants.user))},
                child: Container(
                  width: 80,
                  height: 50,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 2.0,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(4))),
                  child: AppText(
                    text: "내 프로필",
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
           InkWell(
                onTap: () => {Get.to(FriendListScreen(tinode: tinode,))},
                child: Container(
                  width: 70,
                  height: 50,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 2.0,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(4))),
                  child: AppText(
                    text: "친구",
                    color: Colors.black,
                  ),
                ),
              ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
                cacheExtent: double.infinity,
                shrinkWrap: false,
                padding: const EdgeInsets.all(10),
                controller: mainController,
                itemCount: roomList.length,
                reverse: false,
                physics: physics,
                itemBuilder: (BuildContext context, int index) {
                  return AutoScrollTag(
                    key: ValueKey(index),
                    controller: mainController,
                    index: index,
                    child: GestureDetector(
                        onLongPress: () => {},
                        child: Stack(
                          children: [
                            
                              InkWell(
                                onTap: () {
                                  onClickMsgRoom(
                                      roomList[index].topic.toString());
                                },
                                child: Container(
                                  height: 40,
                                  child: Row(children: [
                                    AppText(
                                      text: roomList[index].public !=null ? roomList[index].public['fn'] : "혼자인 방",
                                      fontSize: 30,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    if (roomList[index].updated != null)
                                      AppText(
                                        text: (roomList[index]
                                            .updated
                                            .toString()),
                                        fontSize: 30,
                                        color: Colors.black,
                                      ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                     if (roomList[index].unread != null && roomList[index].unread != 0) ...[
                                    AppText(
                                      text: roomList[index].unread.toString(),
                                      fontSize: 30,
                                      color: Colors.red,
                                    ),]
                                  ]),
                                ),
                              ),
                          ],
                        )),
                  );
                }),
          ),
        ]),
      ),
    );
  }
}
