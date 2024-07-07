import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:tinodeflutter/Constants/Constants.dart';
import 'package:tinodeflutter/Constants/ImageConstants.dart';
import 'package:tinodeflutter/Constants/ImageUtils.dart';
import 'package:tinodeflutter/Constants/utils.dart';
import 'package:tinodeflutter/call/CallScreen.dart';
import 'package:tinodeflutter/call/CallService.dart';
import 'package:tinodeflutter/components/widget/BtnBottomSheetWidget.dart';
import 'package:tinodeflutter/components/widget/GalleryBottomSheet.dart';
import 'package:tinodeflutter/components/MyAssetPicker.dart';
import 'package:tinodeflutter/model/btn_bottom_sheet_model.dart';
import 'package:tinodeflutter/components/widget/image_viewer.dart';
import 'package:tinodeflutter/dto/file_dto.dart';
import 'package:tinodeflutter/global/DioClient.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/setting/setting_chat_expiration_screen.dart';
import 'package:tinodeflutter/tinode/src/models/del-range.dart';
import 'package:tinodeflutter/tinode/src/models/message.dart';
import 'package:tinodeflutter/tinode/tinode.dart';
import 'package:tinodeflutter/utils/write_log.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../tinode/src/database/model.dart';

import 'package:tinodeflutter/app_text.dart';
import 'package:http/http.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

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
  List<User> joinUserList= [];
  late TopicSubscription roomMetaSubData;
  late Topic roomTopicData;
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
   
    roomTopic.onData.listen((data) {
      try {
        if (data != null) {
          if(data.content is String)
            print('DataMessage: ' + data.content);
          else
            print("텍스트가 아닙니다.");
          
          if(msgList.length!=0 &&  msgList[0].seq == data.seq) return;

          //msgList.insert(0, data);
          msgList.add(data);
          setState(() {
            if (data.ts != null) msgList.sort((a, b) => b.ts!.compareTo(a.ts!));
          });
        }
      } catch (err) {
        print("err roomTopic getMsgList : $err");
      }
    });
 
     roomTopic.onMetaDesc.listen((onMetaDesc){
      try{
        roomTopicData = onMetaDesc;
        for(int i = 0 ; i<onMetaDesc.subscribers.length;i++)
        {
         String pictureUrl = roomTopicData.subscribers[i]?.public['photo']['ref'] != null ? changePathToLink(roomTopicData.subscribers[i]?.public['photo']['ref']) : "";
         User user =  User(id: roomTopicData.subscribers[i]?.user ?? "", name:roomTopicData.subscribers[i]?.public['fn'] ?? "" , picture: pictureUrl, isFreind: roomTopicData.subscribers[i]?.isFriend ?? false);
         joinUserList.add(user);
        }
        setState(() {
          print("list length : ${joinUserList.length}");
        });
      }
      catch(err)
      {
        print("meta err : $err");
      }
    });
    //  roomTopic.onMeta.listen((data){
    //   try{
    //     print("$data");
    //     print("meta data ");
    //   }
    //   catch(err)
    //   {
    //     print("meta err : $err");
    //   }
    // });
    // roomTopic.onMetaSub.listen((metaSubData){
    //   try{
    //     roomMetaSubData=metaSubData;
    //     print("meta data ");
    //   }
    //   catch(err)
    //   {
    //     print("meta err : $err");
    //   }
    // });
     try {
      if (!roomTopic.isSubscribed)
        await roomTopic.subscribe(
            MetaGetBuilder(roomTopic).withData(null, null, null).withSub(null, null, null).withDesc(null).build(), null);
    } catch (err) {
      print("err roomTopic getMsgList : $err");
    }
  }

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
        case 'VC':
          print("call");
          if(dataMessage.content['ent'][0]['data']?['aonly']!=null) return eChatType.VOICE_CALL;
          else return eChatType.VIDEO_CALL;
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
        if(!(msgList[0].head?['webrtc']=='missed') && !(msgList[0].head?['webrtc']=='finished') && !(msgList[0].head?['webrtc']=='accepted') && !(msgList[0].head?['webrtc']=='declined')) checkCallState(dataMessage);
        return callTile(index,dataMessage);

      default:
        return Container();
    }
  }

  void checkCallState(DataMessage dataMessage)
  {
    if(dataMessage.from == Constants.user.id) return;  // 내가 걸었던 메시지니깐 따로 처리안함
    if(dataMessage.head?['webrtc']!=null)
    {
     switch(dataMessage.head?['webrtc'])
     {
        case 'started':
          final callService = CallService(joinUserList: joinUserList, roomTopicName: roomTopic.name ?? "");
          callService.showIncomingCall(callerName : joinUserList[0].name ,callerNumber: '', callerAvatar: "");
        break;
        case 'accepted':
        case 'declined':
        break;
        case 'finished':
        case 'missed':
        return;
        default:
        break;
     }

    }
  }

  Widget callTile(int index, DataMessage dataMessage)
  {
    return GestureDetector(
        onLongPress: () => {deleteMsgForAllPerson(msgList[index].seq ?? -1)},
        child: Stack(
          children: [
            Container(
              height: 30,
              child: Row(children: [
                Container(
                  height: 25,
                  color: Colors.grey,
                  child:AppText(
                  text: '통화 ${dataMessage.head?['webrtc']}',
                  color: Colors.black,
                ), 
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
  }

  void fullView(BuildContext context, int index, String imageUrl) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ImageViewer(
                  images: [imageUrl],
                  selected: index,
                  isVideo: false,

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

  Future<String> encodeFileToBase64(File file) async {
    List<int> bytes = await file.readAsBytes();
    String base64Image = base64Encode(bytes);
    return base64Image;
  }

  String fileUrl = "";

  String getFileUrl(DataMessage dataMessage, eChatType fileType) {
    switch(fileType)
    { case eChatType.IMAGE:
        fileUrl ="http://$hostAddres/${dataMessage.content['ent'][0]['data']['ref']}?apikey=$apiKey&auth=token&secret=$url_encoded_token";
        break;
      case eChatType.VIDEO:
        fileUrl ="http://$hostAddres/${dataMessage.content['ent'][0]['data']['preref']}?apikey=$apiKey&auth=token&secret=$url_encoded_token";
        break;
      default:
        break;
    }
    print("file url : $fileUrl");
    return fileUrl;
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
              fullView(
                  context, 0, dataMessage.content['ent'][0]['data']['ref']);
            },
            onLongPress: () {
              deleteMsgForAllPerson(msgList[index].seq ?? -1);
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
                      images: [getFileUrl(dataMessage, eChatType.VIDEO)], // video url
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
        deleteMsgForAllPerson(msgList[index].seq ?? -1);
      },
      child: Container(
          constraints: BoxConstraints(maxWidth: 240),
          child: Stack(
            children: [
              isBase64
                ? getImageBase64Decoder(
                    dataMessage.content['ent'][0]['data']['preview'])
                : getUrltoImage(getFileUrl(dataMessage, eChatType.VIDEO)),
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
      // List<String> imageList = [];

      // // base64 encode
      // for (File item in fileList) {
      //   String base64Image = await encodeFileToBase64(item);
      //   imageList.add(base64Image);
      // }
      
      // WriteLog.write(imageList[0], fileName: "base64.txt");

      await sendImage(fileList);

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

      if (videoList.isNotEmpty && videoList.length == thumbList.length) {
        uploadVideo(videoList, thumbList, 0);
      }
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
      //   showToast("connection_failed");
      // }
      // );
    } else {
      if (videoList.isNotEmpty && videoList.length == thumbList.length) {
        uploadVideo(videoList, thumbList, 0);
      }
    }
  }

  Future<void> procAssetsWithCamera(List<AssetEntity>? assets) async {
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
        await sendImage(fileList);

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

          if (videoList.isNotEmpty && videoList.length == thumbList.length) {
            uploadVideo(videoList, thumbList, 0);
          }
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
        // showToast("connection_failed");
        
        // );

    }
       else { // 이미지 선택 안했을 떄 
        if (videoList.isNotEmpty && videoList.length == thumbList.length) {
          uploadVideo(videoList, thumbList, 0);
        }
      }
    }
  }

  Future<void> uploadVideo(
      List<File> videoList, List<File> thumbList, int index) async {
    if (index == videoList.length) return;

    // List<File> fileList = [];
    // fileList.add(videoList[index]);
    // fileList.add(thumbList[index]);

    int randid = Random().nextInt(10000);

    for(int i =0 ; i<videoList.length;i++)
    {
      try{
      var videoResult = await DioClient.postUploadFile(videoList[i].path);
      var thumbResult = await DioClient.postUploadFile(thumbList[i].path);
      String videoUrlPath = videoResult.data['ctrl']['params']['url'];
      String thumbnailUrlPath = thumbResult.data['ctrl']['params']['url'];
      Message message = Message(
          roomTopic.name,
          {
            "txt": " ",
            "ent": [
              {
                "tp": "VD",
                "data": {"mime": "video/mp4","preref":thumbnailUrlPath , "ref": videoUrlPath,
                "duration": 100, "width":100, "height":100, "size": 100}
              }
            ]
          },
          false, // echo 설정
          head: {"mime": "text/x-drafty"},
        );

        var pub_result = await roomTopic.publishMessage(message);

        if(pub_result?.text =='accepted') showToast('complete video');
      }
      catch(err)
      {
        print("upload video err : $err");
      }
      
      
     
    }


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

  Future<void> sendImage( //List<String> imageList, 
  List<File> fileList) async {
    try {
      for (int i = 0; i < fileList.length; i++) {
        // Message 객체 생성

        // 메시지를 발행하여 서버에 전송
        var result = await DioClient.postUploadFile(fileList[i].path);

        if (result.data['ctrl']['code'] == 200)
          print("${result.data['ctrl']['params']['url'].toString()}");

        String urlPath = result.data['ctrl']['params']['url'];

        Message message = Message(
          roomTopic.name,
          {
            "txt": " ",
            "ent": [
              {
                "tp": "IM",
                "data": {"mime": "image/png", "ref": urlPath}
              }
            ]
          },
          false, // echo 설정
          head: {"mime": "text/x-drafty"},
        );

        var pub_result = await roomTopic.publishMessage(message);

        if(pub_result?.text =='accepted') showToast('complete');
        

        print('이미지가 성공적으로 서버에 전송되었습니다.');

        // 발송한 메시지 만들어주기
        // int seq = msgList.isEmpty ? (msgList[0].seq ?? 0 + 1) : 0;
        // DataMessage datamessage = DataMessage(
        //   topic: roomTopic.name,
        //   content: {
        //     "txt": " ",
        //     "ent": [
        //       {
        //         "tp": "IM",
        //         "data": {
        //           "mime": "image/png",
        //           "ref": result.data['ctrl']['params']['url'].toString()
        //         }
        //       }
        //     ]
        //   },
        //   ts: DateTime.now(),
        //   seq: seq,
        // );
        // setState(() {
        // //  msgList.insert(0, datamessage);
        // });
      }
    } catch (err) {
      print("image send err: $err");
    }
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
      try {
        var result = await roomTopic.publishMessage(msg);
        if (result?.text == "accepted") showToast("chat add");
      } catch (err) {
        print("err : $err");
      }
    } else{
      getMsgList();
      // var s = await roomTopic.subscribe(MetaGetBuilder(roomTopic).withData(null,null,null).build(),null);

      addMsg(input);
    }

  }

  Future<void> requestVoiceCall() async
  {

    Map<String,dynamic> data =  {
            "txt": " ",
            "ent": [
              {
                "tp": "VC",
                "data": {"aonly":true}
              }
            ]
          };

       Map<String,dynamic> head = {
        "aonly":true,
        "mime": "text/x-drafty",
        "webrtc" :"started",
       };
    var voiceMsg = roomTopic.createMessage(data, false, head: head);
    try{
      await roomTopic.publishMessage(voiceMsg);
      Get.to(CallScreen(tinode: tinode, joinUserList: joinUserList));
      
    }
    catch(err)
    {
      print("voice call request err : $err");
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
                            Get.to(SettingChatExpirationeScreen(tinode: tinode, roomTopic: roomTopic));
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
                            requestVoiceCall();
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
