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
import '../components/item/PositionRetainedScrollPhysics.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MessageRoomScreen extends StatefulWidget {
  Tinode tinode;
  String clickTopic;
  MessageRoomScreen(
      {super.key, required this.tinode, required this.clickTopic});

  @override
  State<MessageRoomScreen> createState() => _MessageRoomScreenState();
}

class _MessageRoomScreenState extends State<MessageRoomScreen> {
  late Tinode tinode;
  late Topic roomTopic;
  late Topic me;
  String clickTopic = "";
  List<DataMessage> msgList = [];
  AutoScrollController mainController = AutoScrollController();
  TextEditingController inputController = TextEditingController();
  PositionRetainedScrollPhysics physics = PositionRetainedScrollPhysics();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    tinode = widget.tinode;
    clickTopic = widget.clickTopic;
    getMsgList();
  }

  @override
  void dispose() {
    super.dispose();
    //tinode.leave(clickTopic, false);
  }

  List<TopicSubscription> roomList = [];

  Future<void> getMsgList() async {
    roomTopic = tinode.getTopic(clickTopic);
    try {
      if (!roomTopic.isSubscribed)
        await roomTopic.subscribe(
            MetaGetBuilder(roomTopic).withData(null, null, null).build(), null);
    } catch (err) {
      print("err roomTopic : $err");
    }
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
  }

  Future<void> _pickFile() async {
    final PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        _uploadFile(file);
      }
    }
  }

  Future<void> _uploadFile(XFile file) async {
    // 파일을 Tinode 서버에 업로드하는 코드
    // 예: Tinode의 파일 업로드 API를 사용하여 파일을 업로드
  }

  void _sendMessage(String text, String? mimeType, String? fileUrl) {
    var content = {};
    if (mimeType != null && fileUrl != null) {
      content = {
        'mime': mimeType,
        'val': fileUrl,
      };
    } else {
      content = {
        'txt': text,
      };
    }
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

  void deleteMsg(int msgId) {
    if (msgId == -1) {
      showToast('cant remove');
      return;
    }
    DelRange delRange = DelRange(low: msgId, hi: msgId, all: false);

    List<DelRange> delRangeList = [delRange];
    roomTopic.deleteMessages(delRangeList, true).then((ctrl) {
      print('Message deleted: $ctrl');
    }).catchError((err) {
      print('Failed to delete message: $err');
    });
  }

  Future<void> addMsg(String input) async {
    //await roomTopic.subscribe(MetaGetBuilder(roomTopic).withData(null,null,null).build(),null);
    if (roomTopic.isSubscribed) {
      var msg = roomTopic.createMessage(input, true);
      print("msg : $msg");
      var result = await roomTopic.publishMessage(msg);
      if(result?.text == "accepted")
      showToast("chat add");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("채팅방"),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(children: [
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
                        onLongPress: () =>
                            {deleteMsg(msgList[index].seq ?? -1)},
                        child: Stack(
                          children: [
                            Container(
                              height: 30,
                              child: Row(children: [
                                AppText(
                                  text: msgList[index].content.toString(),
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                AppText(
                                  text: msgList[index].ts.toString(),
                                  color: Colors.grey,
                                ),
                              ]),
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
