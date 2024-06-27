import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'tinode/tinode.dart';
import 'tinode/src/models/message.dart';
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

import 'model/userModel.dart';

class SerachUserScreen extends StatefulWidget {
  Tinode tinode;
  SerachUserScreen({super.key, required this.tinode});

  @override
  State<SerachUserScreen> createState() => _SerachUserScreenState();
}

class _SerachUserScreenState extends State<SerachUserScreen> {
  late Tinode tinode;
  late Topic roomTopic;
  late Topic me;
  AutoScrollController mainController = AutoScrollController();
  TextEditingController inputController = TextEditingController();
  PositionRetainedScrollPhysics physics = PositionRetainedScrollPhysics();
  List<TopicSubscription> roomList = [];
  List<User> _searchResults = [];
  late TopicFnd _fndTopic;

  @override
  void initState() {
    super.initState();
    tinode = widget.tinode;
    _initializeFndTopic();
  }

  String clickTopic = "";
  Future<void> onClickMsgRoom(String clickTopic) async {
    this.clickTopic = clickTopic;
    Get.to(MessageRoomScreen(
      tinode: tinode,
      clickTopic: this.clickTopic,
    ));
  }

  void _initializeFndTopic() {
    _fndTopic = tinode.getTopic('fnd') as TopicFnd;
    _fndTopic.onMeta.listen((value) {
      _handleMetaMessage(value);
    });
  }

  void _handleMetaMessage(MetaMessage msg) {
    if (msg.sub != null) {
      print("search list : $_searchResults");
      setState(() {
        _searchResults = msg.sub!.map((dynamic sub) {
          return User(
            id: sub.user >> 'Unknown ID',
            name: sub.public != null ? sub.public['fn'] ?? 'Unknown' : 'Unknown',
            email: sub.public != null ? sub.public['email'] ?? 'No Email' : 'No Email',
          );
        }).toList();
      });
    }
  }

  Future<void> _searchUsers(String query) async{
    try {

      GetQuery getQuery = GetQuery(
        what: 'sub',
        sub: GetOptsType(user: 'test2'),
      );
      var data = await _fndTopic.getMeta(getQuery);
    } catch (err) {
      print("err search : $err");
    }
  }

  void onClickSearchUser(String inputString) {
    if (inputString.isEmpty) {
      showToast("내용입력");
      return;
    }
    tinode.getFndTopic();

    // TopicDescription desc = new TopicDescription(public: inputString);
    // TopicSubscription sub = new TopicSubscription(topic: "fnd");
    // SetParams setParams = new SetParams(desc: desc,sub: sub);
    // tinode.setMeta(inputString, setParams);
    //GetQuery getQuery = new GetQuery();
    //tinode.getMeta(inputString, getQuery );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("유저검색"),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(children: [
          SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () {
              if(!inputController.value.text.isEmpty)_searchUsers(inputController.value.text);
              else showToast("입력해주세요");
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Container(
              width: 100,
              height: 20,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black)),
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: AppText(
                text: "검색",
                textAlign: TextAlign.center,
                color: Colors.black,
              ),
            ),
          ),

          SizedBox(
            height: 20,
          ),
          Container(
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black)),
              padding: const EdgeInsets.only(
                  left: 20, top: 12, bottom: 12, right: 10),
              child: Column(
                children: [
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
                ],
              )),

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
          //                   InkWell(
          //                     onTap: () {
          //                       onClickMsgRoom(
          //                           roomList[index].topic.toString());
          //                     },
          //                     child: Container(
          //                       height: 40,
          //                       child: Row(children: [
          //                         AppText(
          //                           text: roomList[index].topic.toString(),
          //                           fontSize: 30,
          //                           color: Colors.black,
          //                         ),
          //                         SizedBox(
          //                           width: 10,
          //                         ),
          //                         AppText(
          //                           text: roomList[index].unread.toString(),
          //                           fontSize: 30,
          //                           color: Colors.red,
          //                         ),
          //                       ]),
          //                     ),
          //                   ),
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
