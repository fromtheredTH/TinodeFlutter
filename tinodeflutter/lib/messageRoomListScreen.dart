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
import 'package:tinodeflutter/messageRoomAddScreen.dart';

import 'package:tinodeflutter/messageRoomListScreen.dart';
import 'package:tinodeflutter/messageRoomScreen.dart';
import '../components/item/PositionRetainedScrollPhysics.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_it/get_it.dart';

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

  @override
  void initState() {
    super.initState();
    tinode = widget.tinode;
    getMsgRoomList();
  }

  Future<void> getMsgRoomList() async {
    me = tinode.getMeTopic();
    try {
      me.onSubsUpdated.listen((value) {
        // for (var item in value) {
        //   print('Subscription[' +
        //       item.topic.toString() +
        //       ']: ' +
        //       item.public['fn'] +
        //       ' - Unread Messages:' +
        //       item.unread.toString());
        // }

        setState(() {
          roomList = value;
        });
        print("room List : ${roomList.length}");
      });

      await me.subscribe(MetaGetBuilder(me).withLaterSub(null).build(), null);
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
                  width: 100,
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
                    text: "유저검색",
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: () => {Get.to(MessageRoomAddScreen(tinode: tinode))},
                child: Container(
                  width: 100,
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
                    text: "방 만들기",
                    color: Colors.black,
                  ),
                ),
              ),
            ],
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
                            if (roomList[index].unread != null)
                              InkWell(
                                onTap: () {
                                  onClickMsgRoom(
                                      roomList[index].topic.toString());
                                },
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
                                    if (roomList[index].created != null)
                                      AppText(
                                        text: (roomList[index]
                                            .created
                                            .toString()),
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
