import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'Constants/ColorConstants.dart';
import 'Constants/ImageConstants.dart';
import 'Constants/ImageUtils.dart';
import 'Constants/utils.dart';
import 'components/BtnBottomSheetWidget.dart';
import 'components/GalleryBottomSheet.dart';
import 'components/MyAssetPicker.dart';
import 'components/btn_bottom_sheet_model.dart';
import 'components/image_viewer.dart';
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
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

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
    roomTopic.leave(false);
  }

  Future<void> getMsgList() async {
    roomTopic = tinode.getTopic(clickTopic);
    try {
      if (!roomTopic.isSubscribed)
        await roomTopic.subscribe(
            MetaGetBuilder(roomTopic).withData(null, null, null).build(), null);
    } catch (err) {
      print("err roomTopic getMsgList : $err");
    }
    roomTopic.onData.listen((data) {
      try {
        if (data != null) {
          //print('DataMessage: ' + data.content);
          msgList.insert(0, data);
          setState(() {
            if (data.ts != null) msgList.sort((a, b) => b.ts!.compareTo(a.ts!));
          });
        }
      } catch (err) {
        print("err roomTopic getMsgList : $err");
      }
    });
  }

  void videoRendrProcess() {}
  void audioRenderProcess() {}

  eChatType checkMsgType(DataMessage dataMessage) {
    if (dataMessage.content is Map) {
      print("map content!");
      switch (dataMessage.content['ent'][0]['tp']) {
        case 'IM':
          print("image");
          return eChatType.IMAGE;
        case 'VD':
          print("video");
          return eChatType.VIDEO;
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
        return imageTile(
            context,
            dataMessage,
            getImageBase64Decoder(dataMessage.content['ent'][0]['data']['val']),
            index);
      case eChatType.VIDEO:
        return videoTile(
            context,
            dataMessage,
            getImageBase64Decoder(
                dataMessage.content['ent'][0]['data']['preview']),
            index);
      default:
        return Container();
    }
  }

  void fullView(BuildContext context, int index, Image img) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ImageViewer(
                  images: ["test"],
                  selected: index,
                  isVideo: false,
                  img: img,
                  //  user: getUser(),
                ))).then((value) {
      // if (value == "delete") {
      //   onDelete();
      // }
    });
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

  String videoUrl = "";

  String getVideoUrl(DataMessage dataMessage) {
    videoUrl =
        "http://$hostAddres/${dataMessage.content['ent'][0]['data']['ref']}?apikey=$apiKey&auth=token&secret=$token";
    print("video url : $videoUrl");
    return videoUrl;
  }

  Widget imageTile(
      BuildContext context, DataMessage dataMessage, Image img, int index) {
    return Container(
      constraints: BoxConstraints(maxWidth: Get.width * 0.65),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              fullView(context, 0, img);
            },
            onLongPress: () {
              deleteMsgForAllPerson(msgList[index].seq ?? -1);
            },
            child: img,
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

  String formatMilliseconds(int milliseconds) {
    // 밀리초를 초로 변환
    int totalSeconds = (milliseconds / 1000).floor();

    // 분과 초를 계산
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;

    // 초가 한 자리 수일 경우 앞에 0을 추가
    String formattedSeconds = seconds < 10 ? '0$seconds' : '$seconds';

    return '$minutes:$formattedSeconds';
  }

  Widget videoTile(
    BuildContext context,
    DataMessage dataMessage,
    Image img,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImageViewer(
                      // images: (info.contents ?? '').split(","),
                      images: [getVideoUrl(dataMessage)], // video url
                      selected: 0,
                      isVideo: true,
                      img: img,
                      // user: getUser(),
                    ))).then((value) {
          // if (value == "delete") {
          //   onDelete();
          // }
        });
      },
      onLongPress: () {
        deleteMsgForAllPerson(msgList[index].seq ?? -1);
      },
      child: Container(
          constraints: BoxConstraints(maxWidth: 240),
          child: Stack(
            children: [
              img,
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
                fontSize: 20,
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

  Widget textTile(int index) {
    return GestureDetector(
        onLongPress: () => {deleteMsgForAllPerson(msgList[index].seq ?? -1)},
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
        ));
    // return Container(
    //   constraints: BoxConstraints(maxWidth: Get.width * 0.65),
    //   decoration: BoxDecoration(
    //     color:
    //         mine ? ColorConstants.colorMyMessage : ColorConstants.white5Percent,
    //     borderRadius: BorderRadius.circular(8),
    //   ),
    //   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    //   child: AppText(
    //     text: info.unsended_at != null
    //         ? 'deleted_msg'.tr()
    //         : (info.contents ?? ''),
    //     fontSize: 14,
    //     fontWeight: FontWeight.w400,
    //   ),
    // );
  }

  Future<void> procAssetsWithGallery(List<Medium> assets) async {
    Utils.showDialogWidget(context);
    List<File> fileList = []; //image, audio
    List<File> videoList = []; //video
    List<File> thumbList = []; //video thumbnail
    await Future.forEach<Medium>(assets, (file) async {
      File? f = await file.getFile();
      print("경로 ${f?.path}");
      if (file.mediumType == MediumType.video) {
        videoList.add(f!);
        //thumbnail
        final fileName = await VideoThumbnail.thumbnailFile(
          video: f.path,
          thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: ImageFormat.PNG,
          quality: 100,
        );
        if (fileName != null) {
          thumbList.add(File(fileName));
        }
      } else {
        fileList.add(await ImageUtils.resizeImageFile(f!));
      }
    });
    Get.back();
    if (fileList.isNotEmpty) {
      int randid = Random().nextInt(10000);

      // apiP.uploadFile(
      //     "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}",
      //     fileList, (current, total) {
      //   print("업로드 ${current} / ${total}");
      //   ChatMsgDto emptyDto = ChatMsgDto(
      //       id: -2,
      //       room_id: roomDto.id,
      //       sender_id: me!.id,
      //       type: eChatType.IMAGE.index,
      //       parent_id: -1,
      //       chat_idx: randid);
      //   emptyDto.file = fileList;
      //   emptyDto.fileProgress = current;
      //   emptyDto.totalProgress = total;
      //   receiveMsg(roomDto, emptyDto);
      // }).then((value) {
      // List<ChatMsgDto> list =
      //     msgList.where((e) => (e.id == -2 && e.chat_idx == randid)).toList();
      // if (list.isNotEmpty) {
      //   int index = msgList.indexOf(list.first);
      //   msgList.removeAt(index);
      // }

      // List<FileDto> images =
      //     value.result.where((element) => element.type == "image").toList();
      // List<FileDto> audios =
      //     value.result.where((element) => element.type == "sound").toList();
      // onFileSend(images, eChatType.IMAGE.index);

      // for (int i = 0; i < audios.length; i++) {
      //   //개별적 메시지로 발송
      //   List<FileDto> audio = [audios[i]];
      //   onFileSend(audio, eChatType.AUDIO.index);
      // }

      // if (videoList.isNotEmpty && videoList.length == thumbList.length) {
      //   uploadVideo(videoList, thumbList, 0);
      // }
      // }).catchError((Object obj) {
      //   setState(() {
      //     List<ChatMsgDto> list = msgList
      //         .where((e) => (e.id == -2 && e.chat_idx == randid))
      //         .toList();
      //     if (list.isNotEmpty) {
      //       int index = msgList.indexOf(list.first);
      //       msgList.removeAt(index);
      //     }
      //   });
      //   showToast("connection_failed".tr());
      // }
      // );
    } else {
      if (videoList.isNotEmpty && videoList.length == thumbList.length) {
        uploadVideo(videoList, thumbList, 0);
      }
    }
  }

  Future<void> procAssets(List<AssetEntity>? assets) async {
    if (assets != null) {
      Utils.showDialogWidget(context);
      List<File> fileList = []; //image, audio
      List<File> videoList = []; //video
      List<File> thumbList = []; //video thumbnail
      await Future.forEach<AssetEntity>(assets, (file) async {
        File? f = await file.originFile;

        if (file.type == AssetType.video) {
          videoList.add(f!);
          //thumbnail
          final fileName = await VideoThumbnail.thumbnailFile(
            video: f.path,
            thumbnailPath: (await getTemporaryDirectory()).path,
            imageFormat: ImageFormat.PNG,
            quality: 100,
          );
          if (fileName != null) {
            thumbList.add(File(fileName));
          }
        } else {
          fileList.add(await ImageUtils.resizeImageFile(f!));
        }
      });
      Get.back();
      if (fileList.isNotEmpty) {
        int randid = Random().nextInt(10000);

        // apiP.uploadFile(
        //     "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}",
        //     fileList, (current, total) {
        //   ChatMsgDto emptyDto = ChatMsgDto(
        //       id: -2,
        //       room_id: roomDto.id,
        //       sender_id: me!.id,
        //       type: eChatType.IMAGE.index,
        //       parent_id: -1,
        //       chat_idx: randid);
        //   emptyDto.file = fileList;
        //   emptyDto.fileProgress = current;
        //   emptyDto.totalProgress = total;
        //   receiveMsg(roomDto, emptyDto);
        // }).then((value) {
        //   List<ChatMsgDto> list = msgList
        //       .where((e) => (e.id == -2 && e.chat_idx == randid))
        //       .toList();
        //   if (list.isNotEmpty) {
        //     int index = msgList.indexOf(list.first);
        //     msgList.removeAt(index);
        //   }

        //   List<FileDto> images =
        //       value.result.where((element) => element.type == "image").toList();
        //   List<FileDto> audios =
        //       value.result.where((element) => element.type == "sound").toList();
        //   onFileSend(images, eChatType.IMAGE.index);

        //   for (int i = 0; i < audios.length; i++) {
        //     //개별적 메시지로 발송
        //     List<FileDto> audio = [audios[i]];
        //     onFileSend(audio, eChatType.AUDIO.index);
        //   }

        //   if (videoList.isNotEmpty && videoList.length == thumbList.length) {
        //     uploadVideo(videoList, thumbList, 0);
        //   }
        // }).catchError((Object obj) {
        //   setState(() {
        //     List<ChatMsgDto> list = msgList
        //         .where((e) => (e.id == -2 && e.chat_idx == randid))
        //         .toList();
        //     if (list.isNotEmpty) {
        //       int index = msgList.indexOf(list.first);
        //       msgList.removeAt(index);
        //     }
        //   });
        //   showToast("connection_failed".tr());
        // });
      } else {
        if (videoList.isNotEmpty && videoList.length == thumbList.length) {
          uploadVideo(videoList, thumbList, 0);
        }
      }
    }
  }

  Future<void> uploadVideo(
      List<File> videoList, List<File> thumbList, int index) async {
    if (index == videoList.length) return;

    List<File> fileList = [];
    fileList.add(videoList[index]);
    fileList.add(thumbList[index]);

    int randid = Random().nextInt(10000);

    // apiP.uploadFile(
    //     "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}",
    //     fileList, (current, total) {
    //   ChatMsgDto emptyDto = ChatMsgDto(
    //       id: -2,
    //       room_id: roomDto.id,
    //       sender_id: me!.id,
    //       type: eChatType.VIDEO.index,
    //       parent_id: -1,
    //       chat_idx: randid);
    //   emptyDto.file = thumbList;
    //   emptyDto.fileProgress = current;
    //   emptyDto.totalProgress = total;
    //   receiveMsg(roomDto, emptyDto);
    // }).then((value) {
    //   List<ChatMsgDto> list =
    //       msgList.where((e) => (e.id == -2 && e.chat_idx == randid)).toList();
    //   if (list.isNotEmpty) {
    //     int index = msgList.indexOf(list.first);
    //     msgList.removeAt(index);
    //   }

    //   List<FileDto> thumbs =
    //       value.result.where((element) => element.type == "image").toList();
    //   List<FileDto> videos =
    //       value.result.where((element) => element.type == "video").toList();

    //   List<FileDto> files = [];
    //   if (thumbs.isNotEmpty && videos.isNotEmpty) {
    //     files.add(videos[0]);
    //     files.add(thumbs[0]);
    //     onFileSend(files, eChatType.VIDEO.index);
    //   }

    //   uploadVideo(videoList, thumbList, index + 1);
    // }).catchError((Object obj) {
    //   setState(() {
    //     List<ChatMsgDto> list =
    //         msgList.where((e) => (e.id == -2 && e.chat_idx == randid)).toList();
    //     if (list.isNotEmpty) {
    //       int index = msgList.indexOf(list.first);
    //       msgList.removeAt(index);
    //     }
    //   });
    //   showToast("connection_failed".tr());
    // });
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

  void deleteMsgForAllPerson(int msgId) {
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

  void deleteMsgForOnlyMyRoom(int msgId) {
    if (msgId == -1) {
      showToast('cant remove');
      return;
    }
    DelRange delRange = DelRange(low: msgId, hi: msgId, all: false);

    List<DelRange> delRangeList = [delRange];
    roomTopic.deleteMessages(delRangeList, false).then((ctrl) {
      print('Message deleted: $ctrl');
      setState(() {
        msgList = msgList;
      });
    }).catchError((err) {
      print('Failed to delete message: $err');
    });
  }

  void deleteTopic() // chat room leave
  {
    roomTopic.deleteTopic(false);
    Get.back();
  }

  Future<void> addMsg(String input) async {
    //await roomTopic.subscribe(MetaGetBuilder(roomTopic).withData(null,null,null).build(),null);
    if (roomTopic.isSubscribed) {
      var msg = roomTopic.createMessage(input, true);
      print("msg : $msg");
      var result = await roomTopic.publishMessage(msg);
      if (result?.text == "accepted") showToast("chat add");
    }
  }

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS) {
      if (await Permission.photos.request().isGranted ||
          await Permission.storage.request().isGranted) {
        return true;
      }
    }
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted ||
          await Permission.photos.request().isGranted &&
              await Permission.videos.request().isGranted) {
        return true;
      }
    }
    return false;
  }

  bool closeRoom = false;

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
                      procAssets([assets]);
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
                  AppText(text: '사진/동영상 선택', fontSize: 20,),
                ],
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
                    child: selectMsgWidget(msgList[index], index),
                  );
                }),
          ),
        ]),
      ),
    );
  }
}
