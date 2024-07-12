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
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

   void _initializeTopic() async {
    me = tinode.getMeTopic();
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
    if(a.touched ==null )
    {
      a.touched = DateTime.now();
    }
    if(b.touched==null)
    {
      b.touched = DateTime.now();
    }
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
    print("${a.topic} : ${a.touched} , ${b.topic} : ${b.touched}     count : ${count++}   , a fn : ${a.public?['fn']?? "null"} , b fn : ${b.public?['fn']??"null"}");
    return b.touched!.compareTo(a.touched!);    
  }

  void _setupListeners() async{
    try{
    me.onSubsUpdated.listen((value) {
      print("Subs updated: $value");
      count = 0; 
      setState(() {
        roomList = value;
        roomList.sort(compareRoomList);
      });
    });

    me.onPres.listen((event) async{
      print("Presence event: $event");
      String topic = event.src ?? "";
      int seq = event.seq ?? -1;
      String sender = event.act?? "";
      bool isExistRoom = roomList.any((subscription) => subscription.topic!. contains(topic));
      switch(event.what)
      {
        case 'msg':
         
        break;
        case 'acs': // 방 생성
          Topic roomTopic = tinode.getTopic(topic);
         if(!roomTopic.isSubscribed)
         {
          await roomTopic.subscribe(MetaGetBuilder(roomTopic).withData(null, null, null).withSub(null, null, null).withDesc(null).build(), null);
          TopicSubscription topicSubscription = TopicSubscription(topic: roomTopic.name, acs: roomTopic.acs, public: roomTopic.public, seq: roomTopic.maxSeq,created: roomTopic.created, updated: roomTopic.updated, touched: roomTopic.touched );
          roomList.insert(0,topicSubscription);
          setState(() {
             roomList.sort((a, b) => b.touched!.compareTo(a.touched!));
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
    
    await me.subscribe(MetaGetBuilder(me).withSub(null,null,null).build(), null);

    getMyInfo();
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

    var userId = tinode.getCurrentUserId();
    String pictureUrl = meta.desc?.public['photo']?['ref'] != null ? changePathToLink(meta.desc?.public['photo']['ref']) : "";
    Constants.user = UserModel(id: userId, name: meta.desc.public['fn'], membership: membershipMeta.membership, picture: pictureUrl, isFreind: false);

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
          if(roomList.length==0)
            Expanded(
              child:Container(
              alignment: Alignment.center,
              width: double.maxFinite,
              height: double.maxFinite,
              child: AppText(text: "채팅방이 없습니다.", fontSize: 20,),))
          else
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
                                      text: roomList[index].public !=null ? roomList[index].public['fn'] : (roomList[index].topic ?? "혼자인 방"),
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    if (roomList[index].touched != null)
                                      AppText(
                                        text: (roomList[index]
                                            .touched
                                            .toString()),
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                     if (roomList[index].unread != null && roomList[index].unread != 0) ...[
                                    AppText(
                                      text: roomList[index].unread.toString(),
                                      fontSize: 12,
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
