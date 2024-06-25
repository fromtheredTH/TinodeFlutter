import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tinode/tinode.dart';
import 'package:tinode/src/models/message.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:http/http.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

import 'package:tinodeflutter/messageScreen.dart';
import '../components/item/PositionRetainedScrollPhysics.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_it/get_it.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.title});

  final String title;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late Tinode tinode;

  late Topic roomTopic;
  late Topic me;
  List<DataMessage> msgList = [];
  List<String> msgListTest = ["dfsdfd", "sdfsdfsdf", "sdfsdfsdf"];
  AutoScrollController mainController = AutoScrollController();

  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  TextEditingController inputController = TextEditingController();
  PositionRetainedScrollPhysics physics = PositionRetainedScrollPhysics();
  String id = "";
  String pw = "";
  
  void loginProcesss() async {
    var key = 'AQAAAAABAAC5Ym2pu9wKC_cbu2omxbD6';
    // var host = 'sandbox.tinode.co';
    var host = '54.180.163.159:6060';
    id = idController.value.text == "" ? "test123" : idController.value.text;
    pw = pwController.value.text == "" ? "qwer123!" : pwController.value.text;
    var loggerEnabled = true;
    tinode = Tinode('TinodeFlutter',
        ConnectionOptions(host, key, secure: false), loggerEnabled);
    await tinode.connect();
    print('Is Connected:' + tinode.isConnected.toString());
    //Get.to(MessageRoomScreen());

    try {
      var result = await tinode.loginBasic(id, pw, null);
      print('User Id: ' + result.params['user'].toString());
      showToast("login 완료");
      
      chatList();
    } catch (err) {
      showToast("잘못 입력했습니다");
    }
  }

  Future<void> chatList() async {
    me = tinode.getMeTopic();

    me.onSubsUpdated.listen((value) {
      for (var item in value) {
        print('Subscription[' +
            item.topic.toString() +
            ']: ' +
            item.public['fn'] +
            ' - Unread Messages:' +
            item.unread.toString());
      }
    });
    await me.subscribe(MetaGetBuilder(me).withLaterSub(null).build(), null);

    roomTopic = tinode.getTopic('usrj3JBf2e7XAU');
    roomTopic.onData.listen((value) {
      try {
        if (value != null) {
          print('DataMessage: ' + value.content);
          msgList.insert(0, value);
          setState(() {
            if (value.ts != null)
              msgList.sort((a, b) => b.ts!.compareTo(a.ts!));
          });
          //showToast("${value.content}");
        }
      } catch (err) {
        print("err roomTopic : ");
      }
    });
    await roomTopic.subscribe(
        MetaGetBuilder(roomTopic).withData(null, null, null).build(), null);
  }

  Future<void> onTextSend() async {
    // hideKeyboard();
    if (inputController.text.replaceAll(" ", "").isEmpty) {
      return;
    }
    String content = inputController.text;
    // addMsg(content, 0, replyIdx != -1 ? msgList[replyIdx].id : 0);
    addMsg(content);
  }

  Future<void> deleteMsg(int index) async
  {
     List<DelRange> ranges = [];
   roomTopic.deleteMessages(ranges ,true);
  }

  Future<void> addMsg(String input) async {
    //await roomTopic.subscribe(MetaGetBuilder(roomTopic).withData(null,null,null).build(),null);

    var msg = roomTopic.createMessage(input, true);
    print("msg : $msg");
    await roomTopic.publishMessage(msg);
    showToast("chat add");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(children: [
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
                  controller: idController,
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
                      hintText: 'input id',
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
                  controller: pwController,
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
                      hintText: 'pw input',
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
            // SizedBox 대신 Container를 사용 가능
            width: 100,
            height: 40,
            child: FilledButton(
              onPressed: () {
                loginProcesss();
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Text('login'),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          SizedBox(
              // SizedBox 대신 Container를 사용 가능
              width: double.infinity,
              height: 100,
              child: Column(
                children: [
                  Container(
                    height: 48,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black)),
                    padding: const EdgeInsets.only(
                        left: 20, top: 12, bottom: 12, right: 10),
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
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              hintText: 'input text...',
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
                    // SizedBox 대신 Container를 사용 가능
                    width: 100,
                    height: 30,
                    child: FilledButton(
                      onPressed: () {
                        if (inputController.value.text != "") {
                          addMsg(inputController.value.text);
                          inputController.clear();
                        } else
                          showToast("내용을 입력하세요");
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      child: Text('전송'),
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
                itemCount: msgList.length,
                reverse: true,
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
                            Container(
                              height: 30,
                              child: Row(
                                children:[
                                AppText(
                                text: msgList[index].content.toString(),
                                color: Colors.black,
                              ),
                              SizedBox(width: 10,),
                              AppText(text: msgList[index].ts.toString(), color: Colors.grey,),
                              ]
                            ),
                            )
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
