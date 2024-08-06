import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tinodeflutter/Constants/ImageConstants.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/components/MyAssetPicker.dart';
import 'package:tinodeflutter/components/widget/BtnBottomSheetWidget.dart';
import 'package:tinodeflutter/components/widget/image_viewer.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:tinodeflutter/model/btn_bottom_sheet_model.dart';
import 'package:tinodeflutter/tinode/src/database/model.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {


  
  Widget fileButtonWidget() {
    return InkWell(
      onTap: () async {
        if (closeRoom) return;
        if (await _promptPermissionSetting()) {
          List<BtnBottomSheetModel> items = [];
          items
              .add(BtnBottomSheetModel(ImageConstants.cameraIcon, "camera", 0));
          items
              .add(BtnBottomSheetModel(ImageConstants.albumIcon, "gallery", 1));

          Get.bottomSheet(
              enterBottomSheetDuration: Duration(milliseconds: 100),
              exitBottomSheetDuration: Duration(milliseconds: 100),
              BtnBottomSheetWidget(
                btnItems: items,
                onTapItem: (sheetIdx) async {
                  if (sheetIdx == 0) {
                    AssetEntity? assets =
                        await MyAssetPicker.pickCamera(context, true);
                    if (assets != null) {
                      procAssetsWithCamera([assets]);
                    }
                  } else {
                    if (await _promptPermissionSetting()) {
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          isDismissible: true,
                          backgroundColor: Colors.transparent,
                          constraints: BoxConstraints(
                            minHeight: 0.4,
                            maxHeight: Get.height * 0.95,
                          ),
                          builder: (BuildContext context) {
                            return DraggableScrollableSheet(
                                initialChildSize: 0.5,
                                minChildSize: 0.4,
                                maxChildSize: 0.9,
                                expand: false,
                                builder: (_, controller) => GalleryBottomSheet(
                                      controller: controller,
                                      onTapSend: (results) {
                                        procAssetsWithGallery(results);
                                      },
                                    ));
                          });
                    }
                  }
                },
              ));
        }
      },
      child: Container(
        width: 35,
        height: 35,
        child: Center(
          child: Image.asset(
            closeRoom
                ? "assets/image/ic_add_disable.png"
                : ImageConstants.chatPlus,
            width: 20,
            height: 20,
          ),
        ),
      ),
    );
  }

  void fullView(BuildContext context, int index, String imageUrl) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ImageViewer(
                  fileUrlList: [imageUrl],
                  selected: index,
                  isVideo: false,

                   user: getUser(),
                ))).then((value) {
      // if (value == "delete") {
      //   onDelete();
      // }
    });
  }

  
  Widget imageTile(BuildContext context, DataMessage dataMessage, int index) {
    bool isBase64 = false;
    if (dataMessage.content['ent'][0]['data']['ref'] != null) {
      isBase64 = false;
    } else {
      isBase64 = true;
    }
    return Container(
      constraints: BoxConstraints(maxWidth: Get.width * 0.65),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
               isBase64
                ?fullView(
                  context, 0,  Base64Decoder().convert(dataMessage.content['ent'][0]['data']['val']) as String)
                : fullView(
                  context, 0,   getFileUrl(dataMessage,eChatType.IMAGE) );

                  ;
            },
            onLongPress: () {
              deleteMsgForAllPerson(msgList[index].id ?? -1);
            },
            child: isBase64
                ? getImageBase64Decoder(
                    dataMessage.content['ent'][0]['data']['val'])
                : getUrltoImage(getFileUrl(dataMessage,eChatType.IMAGE)),

            // info.file.isNotEmpty
            //     ? Image.file(
            //         info.file[0],
            //         fit: BoxFit.cover,
            //       )
            //     : CachedNetworkImage(imageUrl: arr[0], fit: BoxFit.cover),
          ),
          // if (info.fileProgress != null &&
          //     info.totalProgress != null &&
          //     info.file != null)
          //   Positioned.fill(
          //       child: Container(
          //     color: Colors.black.withOpacity(0.5),
          //     child: Center(
          //         child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       children: [
          //         CircularPercentIndicator(
          //           radius: 12.0,
          //           lineWidth: 1.0,
          //           percent: info.fileProgress!.toDouble() /
          //               info.totalProgress!.toDouble(),
          //           progressColor: Colors.white,
          //         ),
          //         SizedBox(
          //           height: 2,
          //         ),
          //         AppText(
          //           text:
          //               "${sizeStr(info.fileProgress!, info.totalProgress!)} / ${totalSizeStr(info.totalProgress!)}",
          //           color: Colors.white,
          //           fontSize: 14,
          //         ),
          //       ],
          //     )),
          //   )),
        ],
      ),
    );
  }
  
  String fileUrl = "";
  String getFileUrl(DataMessage dataMessage, eChatType fileType,
      {bool getVideoThumbnail = false}) {
    switch (fileType) {
      case eChatType.IMAGE:
        fileUrl =
            "https://$hostAddres/${dataMessage.content['ent'][0]['data']['ref']}?apikey=$apiKey&auth=token&secret=$url_encoded_token";
        break;
      case eChatType.VIDEO:
        if (getVideoThumbnail)
          fileUrl =
              "https://$hostAddres/${dataMessage.content['ent'][0]['data']['preref']}?apikey=$apiKey&auth=token&secret=$url_encoded_token";
        else {
          fileUrl =
              "https://$hostAddres/${dataMessage.content['ent'][0]['data']['ref']}?apikey=$apiKey&auth=token&secret=$url_encoded_token";
        }
        break;
      default:
        break;
    }
    print("file url : $fileUrl");
    return fileUrl;
  }
  
  late Uint8List imageDecode;

  Image getImageBase64Decoder(String base64) {
    imageDecode = Base64Decoder().convert(base64);
    return Image.memory(
      imageDecode,
      // width: 200,
      // height: 200,
      fit: BoxFit.cover,
      width: Get.width * 0.4,
      height: Get.width * 0.4,
    );
  }
  
  Widget getUrltoImage(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        }
      },
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        return Center(
          child: Text('Failed to load image'),
        );
      },
    );
  }

  
  Widget videoTile(
    BuildContext context,
    DataMessage dataMessage,
    int index,
  ) {
    bool isBase64 = false;
    if (dataMessage.content['ent'][0]['data']['preref'] != null) {
      isBase64 = false;
    } else {
      isBase64 = true;
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImageViewer(
                      // images: (info.contents ?? '').split(","),
                      fileUrlList: [getFileUrl(dataMessage, eChatType.VIDEO, getVideoThumbnail: false),], // video url
                      selected: 0,
                      isVideo: true,
                      // user: getUser(),
                    ))).then((value) {
          // if (value == "delete") {
          //   onDelete();
          // }
        });
      },
      onLongPress: () {
        deleteMsgForAllPerson(msgList[index].id ?? -1);
      },
      child: Container(
          constraints: BoxConstraints(maxWidth: 240),
          child: Stack(
            children: [
              isBase64
                ? getImageBase64Decoder(
                    dataMessage.content['ent'][0]['data']['preview'])
                : getUrltoImage(getFileUrl(dataMessage, eChatType.VIDEO, getVideoThumbnail: true)),
              // info.file.isNotEmpty
              //     ? Image.file(
              //         info.file[0],
              //         fit: BoxFit.cover,
              //       )
              //     : (info.contents ?? '').split(",").length != 2
              //         ? Container(color: Colors.black)
              //         : CachedNetworkImage(
              //             imageUrl: (info.contents ?? '').split(",")[1],
              //             fit: BoxFit.cover,
              //           ),
              // if (info.fileProgress == null &&
              //     info.totalProgress == null &&
              //     info.file.isEmpty)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset(ImageConstants.playVideo,
                      width: 40, height: 40),
                ),
              ),
              AppText(
                text: formatMilliseconds(
                    dataMessage.content['ent'][0]['data']['duration']),
                textAlign: TextAlign.end,
                color: Colors.white,
                fontSize: 12,
              )
              // if (info.fileProgress != null &&
              //     info.totalProgress != null &&
              //     info.file != null)
              //   Positioned.fill(
              //       child: Container(
              //     color: Colors.black.withOpacity(0.5),
              //     child: Center(
              //         child: Column(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       children: [
              //         CircularPercentIndicator(
              //           radius: 12.0,
              //           lineWidth: 1.0,
              //           percent: info.fileProgress!.toDouble() /
              //               info.totalProgress!.toDouble(),
              //           progressColor: Colors.white,
              //         ),
              //         SizedBox(
              //           height: 2,
              //         ),
              //         AppText(
              //           text:
              //               "${sizeStr(info.fileProgress!, info.totalProgress!)} / ${totalSizeStr(info.totalProgress!)}",
              //           color: Colors.white,
              //           fontSize: 14,
              //         ),
              //       ],
              //     )),
              //   )),
            ],
          )),
    );
  }
    eChatType checkMsgType(DataMessage dataMessage) {
    // dynamic data = jsonDecode(dataMessage.content);

    if (dataMessage.content is Map) {
      if (dataMessage.content?['ent'] != null)
        switch (dataMessage.content?['ent'][0]['tp']) {
          case 'IM':
            print("image");
            return eChatType.IMAGE;
          case 'VD':
            print("video");
            return eChatType.VIDEO;
          case 'AU':
            print("audio");
            return eChatType.AUDIO;
          case 'VC':
            print("call");
            if (dataMessage.content['ent'][0]['data']?['aonly'] != null)
              return eChatType.VOICE_CALL;
            else
              return eChatType.VIDEO_CALL;
        }
      return eChatType.NONE;
    } else {
      return eChatType.TEXT;
    }
  }


  Widget selectMsgWidget(DataMessage dataMessage, int index) {
    switch (checkMsgType(dataMessage)) {
      case eChatType.TEXT:
        return textTile(index);
      case eChatType.IMAGE:
        return imageTile(context, dataMessage, index);
      case eChatType.VIDEO:
        return videoTile(
            context,
            dataMessage,
            index);
      case eChatType.VOICE_CALL:
      case eChatType.VIDEO_CALL:
        //Get.to(CallScreen(tinode: tinode, roomTopic: roomTopic, joinUserList: joinUserList,));
       // if(isDifferenceDateTimeLessOneMinute(DateTime.now(),dataMessage.ts)) checkCallState(dataMessage);
        return callTile(index,dataMessage);

      default:
        return Container();
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
              height: 250,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        // SizedBox 대신 Container를 사용 가능
                        width: 120,
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
                          child: Text('text 전송'),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        // SizedBox 대신 Container를 사용 가능
                        width: 100,
                        height: 30,
                        child: FilledButton(
                          onPressed: () {
                            deleteTopic();
                          },
                          child: Text('방 삭제'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            color: Colors.black,
                            width: 30,
                            height: 30,
                          ),
                          fileButtonWidget(),
                        ],
                      ),
                      AppText(
                        text: '사진/동영상 선택',
                        fontSize: 12,
                      ),
                    ],
                  ),
                  SizedBox(
                        // SizedBox 대신 Container를 사용 가능
                        width: 200,
                        height: 30,
                        child: FilledButton(
                          onPressed: () {
                            Get.to(SettingChatExpirationeScreen(tinode: tinode_global, roomTopic: roomTopic));
                          },
                          child: Text('자동삭제조정 설정'),
                        ),
                      ),
               
                      SizedBox(height: 10,),
                      if(roomTopic.isP2P())
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [ 
                           SizedBox(
                        // SizedBox 대신 Container를 사용 가능
                        width: 100,
                        height: 30,
                        child: FilledButton(
                          onPressed: () {
                            requestVoiceCall();
                          },
                          child: Text('음성통화'),
                        ),
                      ),
                         SizedBox(
                        // SizedBox 대신 Container를 사용 가능
                        width: 100,
                        height: 30,
                        child: FilledButton(
                          onPressed: () {
                            requestVideoCall();
                          },
                          child: Text('영상통화'),
                        ),
                      ),
                      ],),
                 
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
                    child: selectMsgWidget(msgList[index], index),
                  );
                }),
          ),
        ]),
      ),
    );
  }

}

 
