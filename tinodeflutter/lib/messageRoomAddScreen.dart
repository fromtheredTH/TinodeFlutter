import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'tinode/tinode.dart';
import 'tinode/src/models/message.dart';
import 'package:tinodeflutter/SearchUser.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:http/http.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

import 'package:tinodeflutter/messageRoomListScreen.dart';
import 'package:tinodeflutter/messageRoomScreen.dart';
import '../components/item/PositionRetainedScrollPhysics.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_it/get_it.dart';
import 'tinode/src/models/access-mode.dart';

class MessageRoomAddScreen extends StatefulWidget {
  Tinode tinode;
  MessageRoomAddScreen({super.key, required this.tinode});

  @override
  State<MessageRoomAddScreen> createState() => _MessageRoomAddScreenState();
}

class _MessageRoomAddScreenState extends State<MessageRoomAddScreen> {
  late Tinode tinode;
  late Topic roomTopic;
  late Topic me;
  AutoScrollController mainController = AutoScrollController();
  TextEditingController inputController = TextEditingController();
  PositionRetainedScrollPhysics physics = PositionRetainedScrollPhysics();
  List<TopicSubscription> roomList = [];

  @override
  void initState() {
    super.initState();
    tinode = widget.tinode;
  }



  List<String> clickFriendList = [];

  late Topic _groupTopic;
  late Topic _opponentTopic;

  Future<void> p2pRoom() async {
    String opponentTopic = "usrPlMch78HvY4";
    // _opponentTopic = tinode.getTopic('usrEiSwIao9WvQ');
    // await _opponentTopic.subscribe( MetaGetBuilder(_opponentTopic).withData(null, null, null).build(), null);
    // _opponentTopic.onData.listen((value) {
    //     print("come");
    //     if(value!=null)
    //     print("_opponentTopic value : ${value.content}");
    //   });
    //Get.back();
    Get.to(() => MessageRoomScreen(tinode: tinode, clickTopic: opponentTopic));
  }

  bool isP2P = false;
  Future<void> onClickMakeRoom() async {
    // 여러명일때는 그룹으로
    // 한명일때는 p2P로
    isP2P ? p2pRoom() : makeGroupRoom();
  }

  void createGroupChat() async {
    // 새로운 그룹 토픽을 생성
    var newTopic = tinode.newTopic();
    // 토픽의 메타데이터 설정
    var setParams = SetParams(
      desc: TopicDescription(
        public: {'fn': 'openChat', 'description': 'This is a public channel'},
        //defacs: DefAcs(auth: 'JRWPAS', anon: 'RWP'),
      ),
      tags: ['public', 'channel'],
    );

    // 토픽 구독 요청
    await tinode.subscribe(newTopic.name.toString(), GetQuery(), setParams);

    // 구독 성공 후 추가 작업 (예: 초기 메시지 보내기)
    inviteUserToGroup('usrEiSwIao9WvQ');
  }

  Future<void> makeGroupRoom() async {
    String groupName = "MyGroup"; // 예시 그룹 이름
    try {
      // 새로운 그룹 토픽 이름 생성
      tinode.newGroupTopicName(true);

      // 새로운 토픽 인스턴스 생성
      _groupTopic = tinode.newTopic();

      // 구독 요청
      await _groupTopic?.subscribe(
          MetaGetBuilder(_groupTopic).withData(null, null, null).build(), null);

      print('Group chat created: $groupName');

      // 메타 데이터 설정
      TopicDescription desc = TopicDescription(
          public: {'fn': groupName, 'description': 'This is a private group'},
          defacs: DefAcs('JRWPAS', ''));
      try {
       // 사용자 초대용 초기 설정
        // TopicSubscription sub = TopicSubscription(
        //   user: 'usrEiSwIao9WvQ',
        //   //mode: 'JRWPAS',
        // );
        SetParams setParams = SetParams(
          desc: desc,
          //sub: sub,
          tags: ['public', 'group'],
        );
        await _groupTopic?.setMeta(setParams);


      print('Meta data updated for group chat: $groupName');

      // 새로운 사용자를 그룹에 초대
      inviteUserToGroup("usrEiSwIao9WvQ");

      } catch (e) {
        print("err sub : $e");
      }

    

      // 메타 데이터 설정 후 추가 작업 (예: 메시지 전송, 사용자 초대 등)
      // _groupTopic?.onData.listen((value) {
      //   print("come");
      //   if (value != null) print("groupTopic value : ${value.content}");
      // });
    } catch (e) {
      print('Failed to create group chat: $e');
    }
  }

  Future<void> inviteUserToGroup(String userId) async {
    try {
      if (_groupTopic == null) {
        throw Exception('Group topic is not initialized.');
      }

      // AccessMode 객체 생성
      // int modeInt = AccessMode.decode('JRWPAS') ?? 0; // 문자열을 정수로 변환
      // AccessMode accessMode = AccessMode(modeInt); // 정수로 AccessMode 초기화
      // String mode = accessMode.getMode() ?? "";

      // 사용자 초대
      await _groupTopic.invite(userId, 'JRWPAS');
      Get.to(()=>MessageRoomScreen(tinode: tinode, clickTopic: _groupTopic.roomId));
      print('User $userId invited to group chat');
    } catch (e) {
      print('Failed to invite user to group chat: $e');
    }
  }

  // Future<void> makeGroupRoom() async {
  //   String groupName = "";
  //   try {
  //     tinode.newGroupTopicName(true);
  //     _groupTopic = tinode.newTopic();

  //     await _groupTopic.subscribe(
  //         MetaGetBuilder(_groupTopic).withData(null, null, null).build(), null);
  //     print('Group chat created: $groupName');

  //     _groupTopic.onData.listen((value) {
  //       print("come");
  //       if (value != null) print("groupTopic value : ${value.content}");
  //     });

  //     // = (data) {
  //     //   setState(() {
  //     //     _messages.add(data.content['txt']);
  //     //   });
  //     // };
  //     Get.back();
  //     Get.to(()=>MessageRoomScreen(tinode: tinode, clickTopic: _groupTopic.name.toString()));
  //   } catch (e) {
  //     print('Failed to create group chat: $e');
  //     Get.back();
  //   }
  // }

  void inviteUser(List<String> members) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("방 만들기"),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(children: [
          InkWell(
            onTap: onClickMakeRoom,
            child: Container(
              width: 100,
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 2.0,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(4))),
              child: AppText(
                text: "완료",
                color: Colors.black,
              ),
            ),
          ),
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black)),
            padding:
                const EdgeInsets.only(left: 20, top: 12, bottom: 12, right: 10),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: inputController,
                  cursorColor: Colors.black,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  onEditingComplete: () {},
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.center,
                  textInputAction: TextInputAction.done,
                  maxLength: 50,
                  decoration: InputDecoration(
                      counterText: "",
                      contentPadding: EdgeInsets.zero,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintText: '유저 검색...',
                      isDense: true,
                      hintStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                      border: InputBorder.none),
                  onChanged: (text) {
                    setState(() {});
                  },
                ),
              ),
            ]),
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
                              onTap: () {},
                              child: Container(
                                height: 40,
                                child: Row(children: [
                                  AppText(
                                    text: roomList[index].topic.toString(),
                                    fontSize: 30,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  AppText(
                                    text: roomList[index].unread.toString(),
                                    fontSize: 30,
                                    color: Colors.red,
                                  ),
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
