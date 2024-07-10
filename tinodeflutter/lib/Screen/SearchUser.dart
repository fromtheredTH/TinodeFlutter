import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tinodeflutter/Screen/ProfileScreen.dart';
import 'package:tinodeflutter/global/global.dart';
import 'messageRoomScreen.dart';
import '../tinode/tinode.dart';
import '../tinode/src/models/message.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:http/http.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

import '../../components/item/PositionRetainedScrollPhysics.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_it/get_it.dart';

import '../model/userModel.dart';

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
  List<UserModel> _searchResults = [];
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

  void _initializeFndTopic() async{
    _fndTopic = tinode.getTopic('fnd') as TopicFnd;
    _fndTopic.onMeta.listen((value) {
      _handleMetaMessage(value);
    });
    if(!_fndTopic.isSubscribed) await _fndTopic.subscribe(MetaGetBuilder(_fndTopic).withData(null, null, null).build(), null);
  }

  void _handleMetaMessage(MetaMessage msg) {
    if (msg.sub != null) {
      setState(() {
        try{
        print("search list :");
        for(int i = 0 ; i<msg.sub!.length ;i++)
        {
          String pictureUrl = msg.sub?[i].public['photo']?['ref'] != null ? changePathToLink(msg.sub?[i].public['photo']['ref']) : "";
          UserModel user = UserModel(id: msg.sub?[i].user ?? "" , name : msg.sub?[i].public['fn'], picture : pictureUrl, isFreind: msg.sub?[i].isFriend ?? false);
          _searchResults.add(user);
        }
        }
        catch(err)
        {
          print("err : $err");
        }
      });
    }
  }

  Future<void> _searchUsers(String query) async {
    try {
      inputController.text="";
      // SetParams 객체를 생성하여 검색 쿼리 설정
      SetParams setParams = SetParams(
        desc: TopicDescription(
          public: query, // 유저 이름을 검색 키워드로 설정
        ),
      );
      // fnd 토픽에 메타데이터 설정 요청 보내기
      var ctrl = await _fndTopic.setMeta(setParams);

   // GetQuery 객체를 생성하여 검색 결과 요청
    GetQuery getQuery = GetQuery(
      topic : _fndTopic.name,
      what: 'sub',
      //sub: GetOptsType(user: query), // 적절한 GetOptsType 설정
    );
    // fnd 토픽에 메타데이터 요청 보내기
    var meta = await _fndTopic.getMeta(getQuery);
    // if(meta?.text=="no content")
    //   showToast("해당 유저없음");
    // 메타데이터 응답 처리
    // if (meta != null && meta.sub != null) {
    //   setState(() {
    //     // _searchResults = meta.sub!.map((sub) {
    //     //   return User(
    //     //     id: sub.user ?? 'Unknown ID',
    //     //     name: sub.public?['fn'] ?? 'Unknown',
    //     //     email: sub.public?['email'] ?? 'No Email',
    //     //     picture: "",
    //     //     nickname: '',
    //     //   );
    //     // }).toList();
    //   });
    //   }
    } catch (err) {
      print("err search : $err");
      isLoading=false;
    }
  }

  void onClickSearchUser(String inputString) {
    if (inputString.isEmpty) {
      showToast("내용입력");
      return;
    }
    tinode.getFndTopic();
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
              if (!inputController.value.text.isEmpty)
                _searchUsers(inputController.value.text);
              else
                showToast("입력해주세요");
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

          Expanded(
            child: ListView.builder(
                cacheExtent: double.infinity,
                shrinkWrap: false,
                padding: const EdgeInsets.all(10),
                controller: mainController,
                itemCount: _searchResults.length,
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
                                Get.to(()=>ProfileScreen(tinode: tinode, user: _searchResults[index]));
                              },
                              child: Container(
                                height: 40,
                                child: Row(children: [
                                  AppText(
                                    text: _searchResults[index].name.toString(),
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  AppText(
                                    text: _searchResults[index].id.toString(),
                                    fontSize: 12,
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
