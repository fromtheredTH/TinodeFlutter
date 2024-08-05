import 'dart:async';
import 'dart:convert';

import 'dart:io';
import 'dart:math';

import 'package:audio_session/audio_session.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/flutter_sound.dart' as fs;
// import 'package:flutter_sound/public/flutter_sound_player.dart';
// import 'package:flutter_sound/public/flutter_sound_recorder.dart';

import 'package:path_provider/path_provider.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:tinodeflutter/Constants/ColorConstants.dart';
import 'package:tinodeflutter/Constants/Constants.dart';
import 'package:tinodeflutter/Constants/FontConstants.dart';
import 'package:tinodeflutter/Constants/ImageConstants.dart';
import 'package:tinodeflutter/Constants/ImageUtils.dart';
import 'package:tinodeflutter/Constants/utils.dart';
import 'package:tinodeflutter/Screen/ProfileScreen.dart';
import 'package:tinodeflutter/call/CallScreen.dart';
import 'package:tinodeflutter/call/CallService.dart';
import 'package:tinodeflutter/call/agoraVoiceCallController.dart';
import 'package:tinodeflutter/components/item/item_chat_msg.dart';
import 'package:tinodeflutter/components/widget/BtnBottomSheetWidget.dart';
import 'package:tinodeflutter/components/widget/GalleryBottomSheet.dart';
import 'package:tinodeflutter/components/MyAssetPicker.dart';
import 'package:tinodeflutter/components/widget/dialog.dart';
import 'package:tinodeflutter/model/MessageModel.dart';
import 'package:tinodeflutter/model/btn_bottom_sheet_model.dart';
import 'package:tinodeflutter/components/widget/image_viewer.dart';
import 'package:tinodeflutter/dto/file_dto.dart';
import 'package:tinodeflutter/global/DioClient.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/page/base/base_state.dart';
import 'package:tinodeflutter/page/base/page_layout.dart';
import 'package:tinodeflutter/setting/setting_chat_expiration_screen.dart';
import 'package:tinodeflutter/tinode/src/models/del-range.dart';
import 'package:tinodeflutter/tinode/src/models/message.dart';
import 'package:tinodeflutter/tinode/tinode.dart';
import 'package:tinodeflutter/utils/write_log.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../tinode/src/database/model.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:tinodeflutter/app_text.dart';
import 'package:http/http.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

import '../components/item/PositionRetainedScrollPhysics.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wav/wav_file.dart';


class MessageRoomScreen extends StatefulWidget {
  String clickTopic;
  Topic? roomTopic;
  MessageRoomScreen(
      {super.key, required this.clickTopic, this.roomTopic});

  @override
  State<MessageRoomScreen> createState() => _MessageRoomScreenState();
}

class _MessageRoomScreenState extends BaseState<MessageRoomScreen> {
  late Topic roomTopic;
  late Topic me;
  String clickTopic = "";
  List<MessageModel> msgList = [];
  AutoScrollController mainController = AutoScrollController();
  TextEditingController inputController = TextEditingController();
  PositionRetainedScrollPhysics physics = PositionRetainedScrollPhysics();
  final ImagePicker _picker = ImagePicker();
  List<UserModel> joinUserList= [];
  late TopicSubscription roomMetaSubData;
  late Topic roomTopicData;

  StreamSubscription? _metaDescSubscription;
  StreamSubscription? _dataSubscription;

  FocusNode myFocusNode = FocusNode();
  int replyIdx = -1;
  RxString durationString = "00:00:00".obs;
  RxString sendString = "".obs;
  String tempString = "";

  //unread timer
  // List<UnreadDto> unreadList = [];
  Timer? unreadTimer;

  //audio
  String? audioFilePath;
  RxBool _isRecording = false.obs;
  RxBool _isRecordLock = false.obs;
  bool _isRecordCancel = false;
  Offset? micFirstX;
  RxDouble? changedX;
  RxDouble? changedY;
  RxDouble? lockX;
  RxDouble? lockY;
  bool _isRecordingFinish = false;

  FlutterSoundPlayer playerModule = FlutterSoundPlayer();
  FlutterSoundRecorder recorderModule = FlutterSoundRecorder();
  bool isRecordSending = false;
  fs.Codec _codec = fs.Codec.pcm16WAV;
  bool? _encoderSupported = true; // Optimist
  bool shouldRemain = false;

  Function? sheetSetState;
  Timer? voiceTimer;
  Duration voiceDuration = const Duration();

  //bottom toast
  double initOffset = 0.0;
  bool bPreview = false;
  bool otherMsg = false;
  int unread_start_id = 0;

  bool isMicPermission = false;


  @override
  void initState() {
    super.initState();
    clickTopic = widget.clickTopic;
    // if(widget.roomTopic!=null) roomTopic = widget.roomTopic!;
    getMsgList();
  }

  @override
  void dispose() {
    super.dispose();
    
    roomTopic.leave(false);
    if(_metaDescSubscription!=null)_metaDescSubscription?.cancel();
    if(_dataSubscription!=null)_dataSubscription?.cancel();
  }
    @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    return super.didChangeAppLifecycleState(state);
  }

  Future<void> getMsgList() async {
   roomTopic = tinode_global.getTopic(clickTopic);
   
    _dataSubscription = roomTopic.onData.listen((data) {
      try {
        if (data != null) {
          if(data.content is String)
            print('DataMessage: ' + data.content);
          else
            print("텍스트가 아닙니다.");
          
          if(msgList.length!=0 &&  msgList[0].dataMessage.seq == data.seq) return;

          MessageModel messageModel = MessageModel(id: data.seq ?? -1 , room_id: data.topic ?? "", created_at: data.ts.toString() ?? "", sender_id: data.from ?? "", type: checkMsgType(data), parent_id: -1, dataMessage: data, contents: data.content);
          //msgList.insert(0, data);
          msgList.add(messageModel);
          setState(() {
            if (data.ts != null) msgList.sort((a, b) => b.dataMessage.ts!.compareTo(a.dataMessage.ts!));
          });
        }
      } catch (err) {
        print("err roomTopic getMsgList : $err");
      }
    });
 
   _metaDescSubscription = roomTopic.onMetaDesc.listen((onMetaDesc) {
  try {
    joinUserList = [];
    roomTopicData = onMetaDesc;
    var subscribersList = onMetaDesc.subscribers.values.toList();
    for (int i = 0; i < subscribersList.length; i++) {
      var subscriber = subscribersList[i];
      if (subscriber != null) {
        String pictureUrl = subscriber.public?['photo']?['ref'] != null
            ? changePathToLink(subscriber.public?['photo']?['ref'])
            : "";
        UserModel user = UserModel(
          id: subscriber.user ?? "",
          name: subscriber.public?['fn'] ?? "",
          picture: pictureUrl,
          isFreind: subscriber.isFriend ?? false,
        );
        joinUserList.add(user);
      }
    }
    setState(() {
      print("list length : ${joinUserList.length}");
    });
  } catch (err) {
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
  // dynamic data = jsonDecode(dataMessage.content);

    if (dataMessage.content is Map) {
    if(dataMessage.content?['ent']!=null)
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
          if(dataMessage.content['ent'][0]['data']?['aonly']!=null) return eChatType.VOICE_CALL;
          else return eChatType.VIDEO_CALL;
      }
      return eChatType.NONE;
    } else {
      return eChatType.TEXT;
    }
  }

  // Widget selectMsgWidget(DataMessage dataMessage, int index) {
  //   switch (checkMsgType(dataMessage)) {
  //     case eChatType.TEXT:
  //       return textTile(index);
  //     case eChatType.IMAGE:
  //       return imageTile(context, dataMessage, index);
  //     case eChatType.VIDEO:
  //       return videoTile(
  //           context,
  //           dataMessage,
  //           index);
  //     case eChatType.VOICE_CALL:
  //     case eChatType.VIDEO_CALL:
  //       //Get.to(CallScreen(tinode: tinode, roomTopic: roomTopic, joinUserList: joinUserList,));
  //      // if(isDifferenceDateTimeLessOneMinute(DateTime.now(),dataMessage.ts)) checkCallState(dataMessage);
  //       return callTile(index,dataMessage);

  //     default:
  //       return Container();
  //   }
  // }

  Future<void> checkCallState(DataMessage dataMessage)async
  {
    if(dataMessage.from == Constants.user.id) return;  // 내가 걸었던 메시지니깐 따로 처리안함
    if(dataMessage.head?['webrtc']!=null)
    {
      if(dataMessage.content['ent'][0]['data']?['aonly']!=null){CallService.instance.chatType = eChatType.VOICE_CALL;}
      else {CallService.instance.chatType = eChatType.VIDEO_CALL;}
     switch(dataMessage.head?['webrtc'])
     {
        case 'started':
          CallService.instance.joinUserList = joinUserList;
          CallService.instance.roomTopicName = roomTopic.name ?? "";
          bool isSettingDone = await CallService.instance.initCallService();
          isSettingDone? CallService.instance.showIncomingCall(roomTopicId: roomTopic.name??"", callerName : joinUserList[0].name ,callerNumber: '', callerAvatar: "") : showToast("fail to call");
    //        WidgetsBinding.instance.addPostFrameCallback((_) async {
    //         Get.to(()=>CallScreen(tinode: tinode, roomTopic: roomTopic,joinUserList: joinUserList,));
    //        //Get.to(AgoraVoiceCallController(channelName: roomTopic?.name ?? ""));
    // });
        break;
        case 'accepted':
        case 'declined':
        case 'disconnected':
        break;
        case 'finished':
        case 'missed':
        return;
        default:
        break;
     }

    }
  }
  bool isDifferenceDateTimeLessOneMinute(DateTime dateTime1, DateTime? dateTime2) {
  // 두 DateTime 객체의 차이를 Duration 객체로 변환
  if(dateTime2==null) return false;
  Duration difference = dateTime1.difference(dateTime2).abs();

  // 차이가 60초 이내인지 확인
  return difference.inSeconds <= 60;
}

  Widget callTile(int index, DataMessage dataMessage)
  {
    return GestureDetector(
        onLongPress: () => {deleteMsgForAllPerson(msgList[index].id ?? -1)},
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
                  text: msgList[index].dataMessage.ts.toString(),
                  color: Colors.grey,
                ),
              ]),
            )
          ],
        )); 
  }

  // void fullView(BuildContext context, int index, String imageUrl) {
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => ImageViewer(
  //                 images: [imageUrl],
  //                 selected: index,
  //                 isVideo: false,

  //                 //  user: getUser(),
  //               ))).then((value) {
  //     // if (value == "delete") {
  //     //   onDelete();
  //     // }
  //   });
  // }

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

  String getFileUrl(DataMessage dataMessage, eChatType fileType, {bool getVideoThumbnail =false}) {
    switch(fileType)
    { case eChatType.IMAGE:
        fileUrl ="https://$hostAddres/${dataMessage.content['ent'][0]['data']['ref']}?apikey=$apiKey&auth=token&secret=$url_encoded_token";
        break;
      case eChatType.VIDEO:
        if(getVideoThumbnail)
        fileUrl ="https://$hostAddres/${dataMessage.content['ent'][0]['data']['preref']}?apikey=$apiKey&auth=token&secret=$url_encoded_token";
        else{
          fileUrl ="https://$hostAddres/${dataMessage.content['ent'][0]['data']['ref']}?apikey=$apiKey&auth=token&secret=$url_encoded_token";
        }
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

  // Widget imageTile(BuildContext context, DataMessage dataMessage, int index) {
  //   bool isBase64 = false;
  //   if (dataMessage.content['ent'][0]['data']['ref'] != null) {
  //     isBase64 = false;
  //   } else {
  //     isBase64 = true;
  //   }
  //   return Container(
  //     constraints: BoxConstraints(maxWidth: Get.width * 0.65),
  //     child: Stack(
  //       children: [
  //         GestureDetector(
  //           onTap: () {
  //              isBase64
  //               ?fullView(
  //                 context, 0,  Base64Decoder().convert(dataMessage.content['ent'][0]['data']['val']) as String)
  //               : fullView(
  //                 context, 0,   getFileUrl(dataMessage,eChatType.IMAGE) );

  //                 ;
  //           },
  //           onLongPress: () {
  //             deleteMsgForAllPerson(msgList[index].id ?? -1);
  //           },
  //           child: isBase64
  //               ? getImageBase64Decoder(
  //                   dataMessage.content['ent'][0]['data']['val'])
  //               : getUrltoImage(getFileUrl(dataMessage,eChatType.IMAGE)),

  //           // info.file.isNotEmpty
  //           //     ? Image.file(
  //           //         info.file[0],
  //           //         fit: BoxFit.cover,
  //           //       )
  //           //     : CachedNetworkImage(imageUrl: arr[0], fit: BoxFit.cover),
  //         ),
  //         // if (info.fileProgress != null &&
  //         //     info.totalProgress != null &&
  //         //     info.file != null)
  //         //   Positioned.fill(
  //         //       child: Container(
  //         //     color: Colors.black.withOpacity(0.5),
  //         //     child: Center(
  //         //         child: Column(
  //         //       mainAxisAlignment: MainAxisAlignment.center,
  //         //       crossAxisAlignment: CrossAxisAlignment.center,
  //         //       children: [
  //         //         CircularPercentIndicator(
  //         //           radius: 12.0,
  //         //           lineWidth: 1.0,
  //         //           percent: info.fileProgress!.toDouble() /
  //         //               info.totalProgress!.toDouble(),
  //         //           progressColor: Colors.white,
  //         //         ),
  //         //         SizedBox(
  //         //           height: 2,
  //         //         ),
  //         //         AppText(
  //         //           text:
  //         //               "${sizeStr(info.fileProgress!, info.totalProgress!)} / ${totalSizeStr(info.totalProgress!)}",
  //         //           color: Colors.white,
  //         //           fontSize: 14,
  //         //         ),
  //         //       ],
  //         //     )),
  //         //   )),
  //       ],
  //     ),
  //   );
  // }

  // Widget videoTile(
  //   BuildContext context,
  //   DataMessage dataMessage,
  //   int index,
  // ) {
  //   bool isBase64 = false;
  //   if (dataMessage.content['ent'][0]['data']['preref'] != null) {
  //     isBase64 = false;
  //   } else {
  //     isBase64 = true;
  //   }
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) => ImageViewer(
  //                     // images: (info.contents ?? '').split(","),
  //                     images: [getFileUrl(dataMessage, eChatType.VIDEO, getVideoThumbnail: false),], // video url
  //                     selected: 0,
  //                     isVideo: true,
  //                     // user: getUser(),
  //                   ))).then((value) {
  //         // if (value == "delete") {
  //         //   onDelete();
  //         // }
  //       });
  //     },
  //     onLongPress: () {
  //       deleteMsgForAllPerson(msgList[index].id ?? -1);
  //     },
  //     child: Container(
  //         constraints: BoxConstraints(maxWidth: 240),
  //         child: Stack(
  //           children: [
  //             isBase64
  //               ? getImageBase64Decoder(
  //                   dataMessage.content['ent'][0]['data']['preview'])
  //               : getUrltoImage(getFileUrl(dataMessage, eChatType.VIDEO, getVideoThumbnail: true)),
  //             // info.file.isNotEmpty
  //             //     ? Image.file(
  //             //         info.file[0],
  //             //         fit: BoxFit.cover,
  //             //       )
  //             //     : (info.contents ?? '').split(",").length != 2
  //             //         ? Container(color: Colors.black)
  //             //         : CachedNetworkImage(
  //             //             imageUrl: (info.contents ?? '').split(",")[1],
  //             //             fit: BoxFit.cover,
  //             //           ),
  //             // if (info.fileProgress == null &&
  //             //     info.totalProgress == null &&
  //             //     info.file.isEmpty)
  //             Positioned.fill(
  //               child: Align(
  //                 alignment: Alignment.center,
  //                 child: Image.asset(ImageConstants.playVideo,
  //                     width: 40, height: 40),
  //               ),
  //             ),
  //             AppText(
  //               text: formatMilliseconds(
  //                   dataMessage.content['ent'][0]['data']['duration']),
  //               textAlign: TextAlign.end,
  //               color: Colors.white,
  //               fontSize: 12,
  //             )
  //             // if (info.fileProgress != null &&
  //             //     info.totalProgress != null &&
  //             //     info.file != null)
  //             //   Positioned.fill(
  //             //       child: Container(
  //             //     color: Colors.black.withOpacity(0.5),
  //             //     child: Center(
  //             //         child: Column(
  //             //       mainAxisAlignment: MainAxisAlignment.center,
  //             //       crossAxisAlignment: CrossAxisAlignment.center,
  //             //       children: [
  //             //         CircularPercentIndicator(
  //             //           radius: 12.0,
  //             //           lineWidth: 1.0,
  //             //           percent: info.fileProgress!.toDouble() /
  //             //               info.totalProgress!.toDouble(),
  //             //           progressColor: Colors.white,
  //             //         ),
  //             //         SizedBox(
  //             //           height: 2,
  //             //         ),
  //             //         AppText(
  //             //           text:
  //             //               "${sizeStr(info.fileProgress!, info.totalProgress!)} / ${totalSizeStr(info.totalProgress!)}",
  //             //           color: Colors.white,
  //             //           fontSize: 14,
  //             //         ),
  //             //       ],
  //             //     )),
  //             //   )),
  //           ],
  //         )),
  //   );
  // }

  Widget textTile(int index) {
    return GestureDetector(
        onLongPress: () => {deleteMsgForAllPerson(msgList[index].id ?? -1)},
        child: Stack(
          children: [
            Container(
              height: 30,
              child: Row(children: [
                AppText(
                  text: msgList[index].contents.toString(),
                  color: Colors.black,
                ),
                SizedBox(
                  width: 10,
                ),
                AppText(
                  text: msgList[index].dataMessage.ts.toString(),
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
        await sendImage(fileList);

        // apiP
        //     .uploadFile("Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", fileList, (current, total){
        //   ChatMsgDto emptyDto = ChatMsgDto(id: -2, room_id: roomDto.id, sender_id: me!.id, type: eChatType.IMAGE.index, parent_id: -1, chat_idx: randid);
        //   emptyDto.file = fileList;
        //   emptyDto.fileProgress = current;
        //   emptyDto.totalProgress = total;
        //   receiveMsg(roomDto, emptyDto);
        // })
        //     .then((value) {
        //   List<ChatMsgDto> list = msgList
        //       .where((e) =>
        //   (e.id == -2 && e.chat_idx == randid))
        //       .toList();
        //   if (list.isNotEmpty) {
        //     int index = msgList.indexOf(list.first);
        //     msgList.removeAt(index);
        //   }

        //   List<FileDto> images = value.result.where((element) => element.type == "image").toList();
        //   List<FileDto> audios = value.result.where((element) => element.type == "sound").toList();
        //   onFileSend(images, eChatType.IMAGE.index);

        //   for (int i = 0; i < audios.length; i++) {
        //     //개별적 메시지로 발송
        //     List<FileDto> audio = [audios[i]];
        //     onFileSend(audio, eChatType.AUDIO.index);
        //   }

          if (videoList.isNotEmpty && videoList.length == thumbList.length) {
            uploadVideo(videoList, thumbList, 0);
          }
        // }).catchError((Object obj) {
        //   setState(() {
        //     List<ChatMsgDto> list = msgList
        //         .where((e) =>
        //     (e.id == -2 && e.chat_idx == randid))
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
      //   DataMessage emptyDto = DataMessage(
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
      // List<DataMessage> list =
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
      //     List<DataMessage> list = msgList
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
        //   DataMessage emptyDto = DataMessage(
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
        //   List<DataMessage> list = msgList
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
        //     List<DataMessage> list = msgList
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
            ],
            "fmt": [{"len":1}],
          },
          false, // echo 설정
          head: {"mime": "text/x-drafty"},
        );
        List<String> videoData = [videoUrlPath,thumbnailUrlPath];
        Map<String,List<String>> extra = {
          "attachments": videoData
        };

        var pub_result = await roomTopic.publishMessage(message, extra:extra );

        if(pub_result?.text =='accepted') showToast('complete video');
      }
      catch(err)
      {
        print("upload video err : $err");
        showToast('300MB까지 가능합니다.');
      }
    }


    // apiP.uploadFile(
    //     "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}",
    //     fileList, (current, total) {
    //   DataMessage emptyDto = DataMessage(
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
    //   List<DataMessage> list =
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
    //     List<DataMessage> list =
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
              },
            ],
            "fmt": [{"len":1}],
          },
          false, // echo 설정
          head: {"mime": "text/x-drafty"},
        );
        List<String> imageData = [urlPath];
        Map<String,List<String>> extra = {
          "attachments": imageData
        };

        var pub_result = await roomTopic.publishMessage(message,extra:extra);

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
      showToast('300MB까지 가능합니다.');
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
  Future<void> deleteChat(int index) async {
    showLoading();
    // apiC
    //     .deleteChat(msgList[index].id, "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}")
    //     .then((value) async {
    //   hideLoading();
    //   print("메세지 삭제");
    //   print(value);
    //   print(value);
    //   setState(() {
    //     msgList[index].type = eChatType.TEXT.index;
    //     // msgList[index].chat_idx = -1;
    //     msgList[index].unsended_at = msgList[index].created_at;
    //   });
    //   ChatUtils.saveChat(roomDto.id, msgList[index]);
    //   widget.roomRefresh(roomDto);
    // }).catchError((Object obj) {
    //   hideLoading();
    //   showToast("connection_failed".tr());
    // });
  }

  Future<void> addMsg(String input) async {
    //await roomTopic.subscribe(MetaGetBuilder(roomTopic).withData(null,null,null).build(),null);

     setState(() {
      replyIdx = -1;
      inputController.text = "";
      sendString.value = "";
    });

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
     Get.to(CallScreen(tinode: tinode_global, roomTopic: roomTopic, joinUserList: joinUserList, chatType: eChatType.VOICE_CALL,));
      // Get.to(AgoraVoiceCallController(channelName: roomTopic?.name ?? ""));

    }
    catch(err)
    {
      print("voice call request err : $err");
    }
  }
  Future<void> requestVideoCall() async
  {

    Map<String,dynamic> data =  {
            "txt": " ",
            "ent": [
              {
                "tp": "VC",
               // "data": {"aonly":false}
              }
            ]
          };

       Map<String,dynamic> head = {
        //"aonly":false,
        "mime": "text/x-drafty",
        "webrtc" :"started",
       };
    var videoCallMsg = roomTopic.createMessage(data, false, head: head);
    try{
      await roomTopic.publishMessage(videoCallMsg);
     Get.to(CallScreen(tinode: tinode_global, roomTopic: roomTopic, joinUserList: joinUserList, chatType: eChatType.VIDEO_CALL,));
      // Get.to(AgoraVoiceCallController(channelName: roomTopic?.name ?? ""));

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

   Future<void> download(List<String> files, int idx) async {
    if (idx == files.length) return;

    String file_path = files[idx];
    String original_file_name = files[idx].split(Platform.pathSeparator).last;
    print("$file_path,$original_file_name");

    PermissionStatus? photos;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        photos = await Permission.storage.request();
      } else {
        photos = await Permission.photos.request();
      }
    } else if (Platform.isIOS) {
      photos = await Permission.photos.request();
    }
    debugPrint(photos?.toString());

    //file download
    String? dir;
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      dir = directory?.path;
    } else {
      dir = (await getApplicationDocumentsDirectory()).absolute.path; //path provider로 저장할 경로 가져오기
    }
    debugPrint(dir);
    if (dir == null) return;

    try {
      await FlutterDownloader.enqueue(
        url: file_path, // file url
        savedDir: dir, // 저장할 dir
        fileName: original_file_name, // 파일명
        showNotification: true, // show download progress in status bar (for Android)
        openFileFromNotification: true, // click on notification to open downloaded file (for Android)
        saveInPublicStorage: true, // 동일한 파일 있을 경우 덮어쓰기 없으면 오류발생함!
      );

      debugPrint("파일 다운로드 완료");
    } catch (e) {
      debugPrint("eerror :::: $e");
    }
    download(files, idx + 1);
  }

  
  Future<bool> onBackPressed() async {
    Navigator.pop(context);
    return false;
  }
   Future<bool> onHide() async {
    hideKeyboard();
    return false;
  }

   Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await recorderModule.openRecorder();

    _encoderSupported = await recorderModule.isEncoderSupported(_codec);

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth | AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    if (!_encoderSupported!) return;
    startRecorder();
  }

  void startRecorder() async {
    try {
      // Request Microphone permission if needed
      if (!kIsWeb) {
        var status = await Permission.microphone.request();
        if (status != PermissionStatus.granted) {
          throw RecordingPermissionException('Microphone permission not granted');
        }
      }
      var path = '';
      if (!kIsWeb) {
        var tempDir = await getTemporaryDirectory();
        path = '${tempDir.path}/flutter_sound${ext[_codec.index]}';
      } else {
        path = '_flutter_sound${ext[_codec.index]}';
      }

      await recorderModule.startRecorder(
        toFile: path,
        codec: _codec,
        bitRate: 8000,
        numChannels: 1,
        sampleRate: 8000,
      );
      recorderModule.logger.d('startRecorder');
      recorderModule.logger.d('audioFilePath=$path');

      audioFilePath = path;

      sheetSetState?.call(() {
        _isRecordingFinish = false;
      });
      startVoiceTimer();
    } on Exception catch (err) {
      recorderModule.logger.e('startRecorder error: $err');
      setState(() {
        stopRecorder();
      });
    }
  }

  void cancelRecorder() async {
    try {
      await recorderModule.stopRecorder();
      recorderModule.logger.d('stopRecorder');
    } on Exception catch (err) {
      recorderModule.logger.d('stopRecorder error: $err');
    }

    voiceTimer?.cancel();

    return;
  }

  void stopRecorder() async {
    print("스탑");
    if(isRecordSending){
      return;
    }

    isRecordSending = true;

    try {
      await recorderModule.stopRecorder();
      recorderModule.logger.d('stopRecorder');
    } on Exception catch (err) {
      recorderModule.logger.d('stopRecorder error: $err');
    }

    voiceTimer?.cancel();

    // change audio file type : stream -> wav
    if (audioFilePath == null) return;
    final wav = await Wav.readFile(audioFilePath!);
    print(wav.format);
    print(wav.samplesPerSecond);

    var path = '';
    if (!kIsWeb) {
      var tempDir = await getTemporaryDirectory();
      path = '${tempDir.path}/tmp${ext[_codec.index]}';
    } else {
      path = '_tmp${ext[_codec.index]}';
    }
    await wav.writeFile(path);
    audioFilePath = path;
    uploadAudio();
  }
  
  final GlobalKey _recorderKey = GlobalKey();
  Offset? _getRecorderOffset() {
    if (_recorderKey.currentContext != null) {
      final RenderBox renderBox =
      _recorderKey.currentContext!.findRenderObject() as RenderBox;
      Offset offset = renderBox.localToGlobal(Offset.zero);
      return offset;
    }
  }
   void startVoiceTimer() {
    //Not related to the answer but you should consider resetting the timer when it starts
    voiceTimer?.cancel();
    voiceDuration = const Duration();
    durationString.value = "00:00:0";
    voiceTimer = Timer.periodic(const Duration(milliseconds: 10), (_) => addVoiceTime());
  }

  void addVoiceTime() {
    final ms = voiceDuration.inMilliseconds + 10;
    voiceDuration = Duration(milliseconds: ms);
    printDuration(voiceDuration);
  }
  void printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoRightDigits(int n) => n.toString().padRight(2, "0");
    String oneDigits(int n) => n.toString().padLeft(1, "0");
    String digitMinutes = oneDigits((duration.inMinutes.remainder(60)).toInt().abs());
    String digitSeconds = twoDigits((duration.inSeconds.remainder(60)).toInt().abs());
    String digitMiliSeconds = twoDigits((duration.inMilliseconds.remainder(1000)/10).toInt());
    durationString.value = "$digitMinutes:$digitSeconds:$digitMiliSeconds";
  }


  Future<void> uploadAudio() async {
    if (audioFilePath == null) return;

    List<File> fileList = [];
    fileList.add(File(audioFilePath!));

    showLoading();
    // apiP
    //     .uploadFile("Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", fileList, (current, totla){

    // })
    //     .then((value) async {

    //   print("푸쉬 테스트 오디오 전송");
    //   hideLoading();
    //   isRecordSending = false;

    //   List<FileDto> audios = value.result.where((element) => element.type == "sound").toList();

    //   onFileSend(audios, eChatType.AUDIO.index);
    // }).catchError((Object obj) {
    //   hideLoading();
    //   isRecordSending = false;
    //   showToast("connection_failed".tr());
    // });
  }

  // Widget messageRoomNameWidget()
  // {
  //   return  Expanded(
  //                         child: GestureDetector(
  //                             onTap: () {
  //                               if (closeRoom) return;
  //                               Navigator.of(context).push(
  //                                   SwipeablePageRoute(
  //                                       canOnlySwipeFromEdge: true,
  //                                       builder: (context) => ChatUserPage(
  //                                         userList: roomDto.joined_users!,
  //                                         me: me!,
  //                                         roomDto: roomDto,
  //                                         changeRoom: (room){
  //                                           widget.changeRoom(room);
  //                                         },
  //                                       )));
  //                             },
  //                             child: Column(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [

  //                                 closeRoom || (roomDto.joined_users?.length ?? 0) == 0 ? roomDto.is_group_room == 0 ? AppText(
  //                                   text: roomDto.is_my_room == 1 ? Constants.user.nickname : roomDto.personal_target?.nickname ?? "",
  //                                   fontSize: 16,
  //                                   maxLength: 1,
  //                                   overflow: TextOverflow.ellipsis,
  //                                   fontWeight: FontWeight.w700,
  //                                 )
  //                                     : AppText(
  //                                   text: 'unknown'.tr(),
  //                                   fontSize: 16,
  //                                   maxLength: 1,
  //                                   overflow: TextOverflow.ellipsis,
  //                                   fontWeight: FontWeight.w700,
  //                                 ) : (roomDto.has_name ?? false) ? AppText(
  //                                   text: (roomDto.name ?? ''),
  //                                   fontSize: 16,
  //                                   overflow: TextOverflow.ellipsis,
  //                                   maxLength: 1,
  //                                   fontWeight: FontWeight.w700,
  //                                 ) : (roomDto.joined_users?.length ?? 0) > 1 ? AppText(
  //                                   text: makeRoomName(),
  //                                   fontSize: 16,
  //                                   overflow: TextOverflow.ellipsis,
  //                                   maxLength: 1,
  //                                   fontWeight: FontWeight.w700,
  //                                 ) : UserNameWidget(user: getOnlyOneUser()),

  //                                 SizedBox(height: 5,),

  //                                 AppText(
  //                                   text: "On-line",
  //                                   color: ColorConstants.halfWhite,
  //                                   fontSize: 10,
  //                                   fontWeight: FontWeight.w400,
  //                                 )
  //                               ],
  //                             )
  //                         ),
  //                       );
  // }

  // Widget topMeetBallWidget()
  // {
  //   return InkWell(
  //                         onTap: (){
  //                           List<BtnBottomSheetModel> items = [];
  //                           if((roomDto.joined_users?.length ?? 0) >= 1)
  //                             items.add(BtnBottomSheetModel(ImageConstants.addChatUserIcon, "add_room_member".tr(), 0));
  //                           if((roomDto.joined_users?.length ?? 0) >= 1 && !closeRoom)
  //                             items.add(BtnBottomSheetModel(ImageConstants.editRoomIcon, "change_room_name".tr(), 1));
  //                           if((roomDto.joined_users?.length ?? 0) == 1 && !closeRoom)
  //                             items.add(BtnBottomSheetModel(ImageConstants.banUserIcon, "user_block".tr(), 2));
  //                           if((roomDto.joined_users?.length ?? 0) == 1 && !closeRoom)
  //                             items.add(BtnBottomSheetModel(ImageConstants.reportUserIcon, "report_title".tr(), 3));
  //                           items.add(BtnBottomSheetModel(ImageConstants.exitRoomIcon, "chat_leave".tr(), 4));
  //                           Get.bottomSheet(enterBottomSheetDuration: Duration(milliseconds: 100), exitBottomSheetDuration: Duration(milliseconds: 100),BtnBottomSheetWidget(
  //                             btnItems: items,
  //                             onTapItem: (menuIndex) async {
  //                               if(menuIndex == 0){
  //                                 Navigator.of(context).push(
  //                                     SwipeablePageRoute(
  //                                         canOnlySwipeFromEdge: true,
  //                                         builder: (context) => ChatAddPage(
  //                                           existUsers: roomDto.joined_users ?? [],
  //                                           room: roomDto,
  //                                           roomIdx: roomDto.id,
  //                                 refresh: (){
  //                                   getChatRoomInfo();
  //                                 },changeRoom: (room){
  //                                     widget.changeRoom(room);
  //                                   },)))
  //                                     .then((value) {

  //                                 });
  //                               }else if(menuIndex == 1){
  //                                 Get.bottomSheet(enterBottomSheetDuration: Duration(milliseconds: 100), exitBottomSheetDuration: Duration(milliseconds: 100),EditRoomNameBottomSheet(
  //                                   roomDto: roomDto,
  //                                   inputName: (name) async {
  //                                     if (name.isEmpty) {
  //                                       return;
  //                                     }
  //                                     showLoading();
  //                                     Map<String, dynamic> body = {
  //                                       "name": name,
  //                                       "room_id": roomDto.id,
  //                                     };
  //                                     apiC
  //                                         .changeRoomName("Bearer ${await FirebaseAuth
  //                                         .instance.currentUser?.getIdToken()}",
  //                                         jsonEncode(body))
  //                                         .then((value) {
  //                                       hideLoading();
  //                                       setState(() {
  //                                         roomDto.has_name = true;
  //                                         roomDto.name = name;
  //                                       });
  //                                     }).catchError((Object obj) {
  //                                       hideLoading();
  //                                       showToast("connection_failed".tr());
  //                                     });
  //                                   },
  //                                 ));
  //                               }else if(menuIndex == 2){
  //                                 List<UserModel> users = roomDto.joined_users ?? [];
  //                                 for(int i=0;i<users.length;i++){
  //                                   if(users[i].id != Constants.user.id){
  //                                     var response = await DioClient.postUserBlock(users[i].id);
  //                                     Utils.showToast("ban_complete".tr());
  //                                     break;
  //                                   }
  //                                 }
  //                               }else if(menuIndex == 3){
  //                                 List<UserModel> users = roomDto.joined_users ?? [];
  //                                 for(int i=0;i<users.length;i++){
  //                                   if(users[i].id != Constants.user.id){
  //                                     showModalBottomSheet<dynamic>(
  //                                         isScrollControlled: true,
  //                                         context: context,
  //                                         useRootNavigator: true,
  //                                         backgroundColor: Colors.transparent,
  //                                         builder: (BuildContext bc) {
  //                                           return ReportUserDialog(onConfirm: (reportList, reason) async {
  //                                             var response = await DioClient.reportUser(users[i].id, reportList, reason);
  //                                             Utils.showToast("report_complete".tr());
  //                                           },);
  //                                         }
  //                                     );
  //                                     break;
  //                                   }
  //                                 }
  //                               }else {
  //                                 AppDialog.showConfirmDialog(context, "leave_title".tr(), "leave_content".tr(), () {
  //                                   chatRoomLeave();
  //                                 });
  //                               }
  //                             },
  //                           ));
  //                         },
  //                         child: Container(
  //                             width: 24,
  //                             height: 24,
  //                             margin: EdgeInsets.only(right: 10),
  //                             child: Center(
  //                               child: Image.asset(ImageConstants.moreWhite, width: 24, height: 24),
  //                             )),
  //                       );
  // }

  Widget audioButtonWidget()
  {
    return Container(
                                          width: double.maxFinite,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children:[
                                              Container(),

                                              Obx(() => GestureDetector(
                                                child: Container(
                                                    width: _isRecording.value ? 200 : 40,
                                                    height: 30,
                                                    color: Colors.transparent,
                                                    child: Stack(
                                                      children: [
                                                        if(_isRecording.value)
                                                          Positioned(
                                                            top:0,
                                                            bottom: 0,
                                                            left: 0,
                                                            child: Image.asset(ImageConstants.micSlideGuide, fit: BoxFit.cover,
                                                              height: 45,),
                                                          ),

                                                        if(!_isRecording.value)
                                                          Positioned(
                                                              top: 0,
                                                              bottom:0,
                                                              right: 10,
                                                              child: Container(
                                                                width: 30,
                                                                height: 30,
                                                                key: _recorderKey,
                                                                child: Image.asset(closeRoom ? ImageConstants.chatMicDisable : !_isRecording.value ? ImageConstants.chatMic : ImageConstants.micPressed, width: 30, height: 30),
                                                              )
                                                          )
                                                      ],
                                                    )
                                                ),
                                                onHorizontalDragEnd: (detail) {
                                                  if(closeRoom)
                                                    return;
                                                  if(_isRecordLock.value){
                                                    lockX!.value = micFirstX!.dx;
                                                    lockY!.value = micFirstX!.dy;
                                                  }
                                                },
                                                onHorizontalDragUpdate: (detail) {
                                                  print("왼쪽으로??");
                                                  if(closeRoom || !_isRecordLock.value)
                                                    return;
                                                  if (micFirstX!.dx -
                                                      detail.globalPosition.dx >= 10) {
                                                    if (micFirstX!.dx -
                                                        detail.globalPosition.dx <=
                                                        80) {
                                                      print("이동");
                                                      // if(changedX == null){
                                                      //   changedX = lockX;
                                                      // }
                                                      // if(changedY == null){
                                                      //   changedY = lockY;
                                                      // }
                                                      lockX!.value = detail.globalPosition.dx;
                                                      lockY!.value = micFirstX!.dy;
                                                      print("${micFirstX!.dx -
                                                          detail.globalPosition
                                                              .dx}만큼 왼쪽으로 움직여서 ${lockX!.value}");
                                                    }

                                                    // 취소
                                                    if (micFirstX!.dx -
                                                        detail.globalPosition.dx >=
                                                        80) {
                                                      _isRecording.value = false;
                                                      _isRecordLock.value = false;
                                                      _isRecordCancel = true;
                                                      changedX = null;
                                                      changedY = null;
                                                      lockX = null;
                                                      lockY = null;
                                                      micFirstX = null;
                                                      cancelRecorder();
                                                      inputController.text = tempString;
                                                    }
                                                  }
                                               },
                                                onLongPressMoveUpdate: (detail) {
                                                  if(closeRoom)
                                                    return;
                                                  if (micFirstX != null) {
                                                    // 왼쪽 취소부터 체크
                                                    print("이동1 ${micFirstX!.dx} - ${detail.globalPosition.dx} = ${micFirstX!.dx - detail.globalPosition.dx}");
                                                    if (micFirstX!.dx -
                                                        detail.globalPosition.dx >= 10) {
                                                      if (micFirstX!.dx -
                                                          detail.globalPosition.dx <=
                                                          80) {
                                                        print("이동");
                                                        // if(changedX == null){
                                                        //   changedX = lockX;
                                                        // }
                                                        // if(changedY == null){
                                                        //   changedY = lockY;
                                                        // }
                                                        lockX!.value = detail.globalPosition.dx;
                                                        lockY!.value = micFirstX!.dy;
                                                        changedX!.value = detail.globalPosition.dx;
                                                        changedY!.value = micFirstX!.dy;
                                                        print("${micFirstX!.dx -
                                                            detail.globalPosition
                                                                .dx}만큼 왼쪽으로 움직여서 ${lockX!.value}");
                                                      }

                                                      // 취소
                                                      if (micFirstX!.dx -
                                                          detail.globalPosition.dx >=
                                                          80) {
                                                        _isRecording.value = false;
                                                        _isRecordLock.value = false;
                                                        _isRecordCancel = true;
                                                        changedX = null;
                                                        changedY = null;
                                                        lockX = null;
                                                        lockY = null;
                                                        micFirstX = null;
                                                        cancelRecorder();
                                                        inputController.text = tempString;
                                                      }
                                                    }else if (micFirstX!.dy -
                                                        detail.globalPosition.dy >= 10 && micFirstX!.dx -
                                                        detail.globalPosition.dx < 10 && !_isRecordLock.value) {
                                                      print("${micFirstX!.dy -
                                                          detail.globalPosition
                                                              .dy}만큼 위쪽으로 움직임");
                                                      if(micFirstX!.dy -
                                                          detail.globalPosition
                                                              .dy <= 100) {
                                                        print("이동");
                                                        changedX!.value = micFirstX!.dx;
                                                        changedY!.value = detail.globalPosition.dy;
                                                      }else {
                                                        _isRecordLock.value = true;
                                                        changedX = lockX;
                                                        changedY = lockY;
                                                        print("녹음 락");
                                                      }
                                                    }
                                                  }
                                                },
                                                onTap: (){
                                                  print("호옹??");
                                                  if(closeRoom)
                                                    return;
                                                  if(!_isRecordLock.value && !_isRecordCancel) {
                                                    showToast("audio_tap_toast".tr());
                                                  }else{

                                                  }
                                                },
                                                onLongPressStart: (detail) async {
                                                  if(closeRoom)
                                                    return;
                                                  if(_isRecordCancel) {
                                                    return;
                                                  }
                                                  if(!isMicPermission){
                                                    isMicPermission = (await Permission.microphone.request()).isGranted;
                                                    return;
                                                  }
                                                  if(!_isRecording.value){
                                                    voiceDuration = const Duration();
                                                    durationString.value = "00:00:0";
                                                    openTheRecorder();
                                                    _isRecording.value = true;
                                                    _isRecordLock.value = false;
                                                    print("글로벌 포지션 ${micFirstX}");
                                                    Offset? recorderOffset = _getRecorderOffset();
                                                    if(recorderOffset != null){
                                                      changedX = recorderOffset!.dx.obs;
                                                      changedY = recorderOffset!.dy.obs;
                                                      lockX = recorderOffset!.dx.obs;
                                                      lockY = recorderOffset!.dy.obs;
                                                      micFirstX = recorderOffset!;
                                                    }else {
                                                      changedX =
                                                          detail.globalPosition.dx
                                                              .obs;
                                                      changedY =
                                                          detail.globalPosition.dy
                                                              .obs;
                                                      lockX = detail.globalPosition.dx
                                                          .obs;
                                                      lockY = detail.globalPosition.dy
                                                          .obs;
                                                      micFirstX = detail.globalPosition;
                                                    }
                                                  }
                                                  tempString = inputController.text;
                                                  inputController.text = " ";
                                                },
                                                onLongPressEnd: (detail){
                                                  print("gg?");
                                                  if(closeRoom)
                                                    return;
                                                  if(_isRecordCancel) {
                                                    _isRecordCancel = false;
                                                    return;
                                                  }
                                                  if(!_isRecordLock.value) {
                                                    _isRecording.value = false;
                                                    stopRecorder();
                                                    inputController.text = tempString;
                                                  }else{

                                                    lockX!.value = micFirstX!.dx;
                                                    lockY!.value = micFirstX!.dy;
                                                  }
                                                },
                                                onTapUp: (detail){
                                                  if(closeRoom)
                                                    return;
                                                  if(_isRecordLock.value){
                                                    _isRecording.value = false;
                                                    _isRecordLock.value = false;
                                                    micFirstX = null;
                                                    changedX = null;
                                                    changedY = null;
                                                    _isRecordCancel = true;
                                                    stopRecorder();
                                                    inputController.text = tempString;
                                                  }else{
                                                    print("gg?");
                                                    lockX!.value = micFirstX!.dx;
                                                    lockY!.value = micFirstX!.dy;
                                                  }
                                                },
                                              )
                                              )


                                            ],
                                          ),
                                        );
  }


  Widget inputBox()
  {
    return   Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Container(
                                    constraints: BoxConstraints(
                                        minHeight: 50),
                                    margin: const EdgeInsets.only(left: 10, top: 15, bottom: 15, right: 5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: ColorConstants.black10Percent
                                    ),
                                    width: double.infinity,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [

                                        Container(
                                          width: double.maxFinite,
                                          margin: EdgeInsets.only(right: 30),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [

                                            Obx(() => _isRecording.value || _isRecordLock.value ?
                                                Row(
                                                  children:[
                                                    SizedBox(width: 10),
                                                    Container(
                                                      width: 6,
                                                      height: 6,
                                                      decoration: BoxDecoration(
                                                          color: Color(0xffeb5757),
                                                          borderRadius: BorderRadius.circular(3)
                                                      ),
                                                    ),

                                                    SizedBox(width: 5,),
                                                    Obx(() => AppText(
                                                      text: durationString.value,
                                                      color: ColorConstants.halfWhite,
                                                      fontSize: 14,
                                                    ))
                                                  ]
                                                ) : Row(
                                              children: [
                                                const SizedBox(width: 7),
                                                // InkWell(
                                                //   onTap: () async {
                                                //     if (closeRoom) return;
                                                //     if (await _promptPermissionSetting()) {
                                                //       List<BtnBottomSheetModel> items = [];
                                                //       items.add(BtnBottomSheetModel(ImageConstants.cameraIcon, "camera".tr(), 0));
                                                //       items.add(BtnBottomSheetModel(ImageConstants.albumIcon, "gallery".tr(), 1));

                                                //       Get.bottomSheet(enterBottomSheetDuration: Duration(milliseconds: 100), exitBottomSheetDuration: Duration(milliseconds: 100),BtnBottomSheetWidget(
                                                //         btnItems: items,
                                                //         onTapItem: (sheetIdx) async {
                                                //           if(sheetIdx == 0){
                                                //             AssetEntity? assets = await MyAssetPicker.pickCamera(context, true);
                                                //             if (assets != null) {
                                                //               procAssets([assets]);
                                                //             }
                                                //           }else {
                                                //             if (await _promptPermissionSetting()) {
                                                //               showModalBottomSheet(
                                                //                   context: context,
                                                //                   isScrollControlled: true,
                                                //                   isDismissible: true,
                                                //                   backgroundColor: Colors.transparent,
                                                //                   constraints: BoxConstraints(
                                                //                     minHeight: 0.4,
                                                //                     maxHeight: Get.height*0.95,
                                                //                   ),
                                                //                   builder: (BuildContext context) {
                                                //                     return DraggableScrollableSheet(
                                                //                         initialChildSize: 0.5,
                                                //                         minChildSize: 0.4,
                                                //                         maxChildSize: 0.9,
                                                //                         expand: false,
                                                //                         builder: (_, controller) => GalleryBottomSheet(
                                                //                           controller: controller,
                                                //                           onTapSend: (results){
                                                //                             procAssetsWithGallery(results);
                                                //                           },
                                                //                         )
                                                //                     );
                                                //                   }
                                                //               );
                                                //             }
                                                //           }
                                                //         },
                                                //       ));
                                                //     }
                                                //   },
                                                //   child: Container(
                                                //     width: 35,
                                                //     height: 35,
                                                //     child: Center(
                                                //       child: Image.asset(
                                                //         closeRoom ? "assets/image/ic_add_disable.png" : ImageConstants.chatPlus,
                                                //         width: 20,
                                                //         height: 20,
                                                //         color: Colors.black,
                                                //       ),
                                                //     ),
                                                //   ),
                                                // ),
                                                const SizedBox(width: 10),
                                              ],
                                            )
                                            ),

                                              Expanded(
                                                child:
                                                Obx(() => TextField(
                                                  focusNode: myFocusNode,
                                                  maxLines: 4,
                                                  minLines: 1,
                                                  maxLength: 5000,
                                                  enabled: !closeRoom,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: FontConstants.AppFont,
                                                      fontSize: 14
                                                  ),
                                                  showCursor: !_isRecording.value,
                                                  controller: inputController,
                                                  decoration: InputDecoration(
                                                      counterText: "",
                                                      hintText: closeRoom ? "disable_chat".tr() : "input_msg".tr(),
                                                      hintStyle: TextStyle(
                                                          color: ColorConstants.halfBlack,
                                                          fontSize: 14,
                                                          fontFamily: FontConstants.AppFont,
                                                          fontWeight: FontWeight.w400,
                                                      ),
                                                      border: InputBorder.none,
                                                      contentPadding: const EdgeInsets.only(bottom: 5)
                                                  ),
                                                  onChanged: (text) {
                                                    sendString.value = text;
                                                  },
                                                ))
                                              ),
                                              const SizedBox(width: 10),
                                            ],
                                          ),
                                        ),
                                        // audio
                                        //audioButtonWidget(),
                                      ],
                                    )
                                )
                            ),

                            GestureDetector(
                              onTap: onTextSend,
                              child: Obx(() => Container(
                                width: 40,
                                height: 40,
                                child: Center(
                                    child: sendString.value.replaceAll(" ", "").isNotEmpty ? Image.asset(ImageConstants.sendChatBnt, width: 30, height: 30, ) : Image.asset(ImageConstants.sendChatDisableBnt, width: 30, height: 30)
                                ),
                              ),)
                            ),

                            SizedBox(width: 5,)
                          ],
                        );
                      },
                    )
                  );
  }

  Widget replyPreviewWidget()
  {
    return   Container(
                      child: Column(
                        children: [
                          Container(
                            height: 0.3,
                            width: double.maxFinite,
                            color: ColorConstants.halfWhite,
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              SizedBox(width: 20,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      text: "replied_top_message".tr(args: ["${msgList[replyIdx].sender_id}"]),
                                      fontSize: 10,
                                      color: ColorConstants.halfWhite,
                                    ),
                                    AppText(
                                      text: msgList[replyIdx]?.unsended_at != null ? "deleted_msg".tr() : chatContent(msgList[replyIdx].contents ?? '', msgList[replyIdx].type),
                                      fontSize: 12,
                                      maxLine: 1,
                                      overflow: TextOverflow.ellipsis,
                                      color: Colors.white70,
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      replyIdx = -1;
                                    });
                                  },
                                  child: Image.asset(ImageConstants.chatX, width: 24, height: 24)),
                              SizedBox(width: 50,)
                            ],
                          ),
                        ],
                      )
                    );
  }

  Widget messageDisplaySpaceWidget()
  {
    return Expanded(
                          child: ListView.builder(
                            cacheExtent: double.infinity,
                            padding: const EdgeInsets.all(10),
                            controller: mainController,
                            itemCount: msgList.length,
                            reverse: true,
                            // physics: const ClampingScrollPhysics(),
                            physics: physics,
                            itemBuilder: (BuildContext context, int index) {
                              // print('testtest itemchatmsg index : ${index}');
                              // WriteLog.write("itemchatmsg index ${index} t : ${DateTime.now()}",fileName: "itemchatmsg.txt");
                              // if(msgList[index].type >= 5){
                              //   return Container();
                              // }
                              Key key = Key(msgList[index].id.toString());
                              return SwipeTo(
                                key: key,
                                  onLeftSwipe: (details){
                                   // print("스와이프 인덱스 ${index}번째 ${msgList[index].contents}");
                                    if (msgList[index].id == -1) return;
                                    setState(() {
                                      replyIdx = index;
                                    });
                                    myFocusNode.requestFocus();
                                  },
                                  swipeSensitivity: 5,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: msgList.length-1 > index && msgList[index+1].dataMessage.from != msgList[index].sender_id ? 15 : 0),
                                    child: AutoScrollTag(
                                      key: ValueKey(index),
                                      controller: mainController,
                                      index: index,
                                      child: ItemChatMsg(
                                          users: joinUserList, //roomDto.joined_users!,
                                          info: msgList[index],
                                        //  unread: unreadList,
                                          me: Constants.user!,
                                          before: index == msgList.length - 1 ? null : msgList[index + 1],
                                          next: index == 0 ? null : msgList[index - 1],
                                          parentNick: parentChatNick(
                                              joinUserList, Constants.user, msgList, msgList[index].parent_chat?.id ?? 0),
                                          bNewMsg: msgList[index].id == unread_start_id,
                                          playerModule:
                                          msgList[index].type != eChatType.AUDIO.index ? null : playerModule,
                                          setState: () {
                                            setState(() {

                                            });
                                          },
                                          onProfile: () async {
                                            Utils.showDialogWidget(context);
                                            try {
                                              // var response = await DioClient
                                              //     .getUser(msgList[index].sender
                                              //     ?.nickname ?? "");
                                              // UserModel user = UserModel
                                              //     .fromJson(response
                                              //     .data["result"]["target"]);
                                              // Get.back();
                                              // if(user.id != 0) {
                                              //   Get.to(ProfileScreen(user: user));
                                              // }
                                            }catch(e){
                                              Get.back();
                                            }
                                          },
                                          onDelete: () {
                                            if (msgList[index].id == -1) return;
                                            deleteChat(index);
                                          },
                                          onTap: () {
                                            if (msgList[index].id == -1) {
                                              List<BtnBottomSheetModel> items = [];
                                              items.add(BtnBottomSheetModel(ImageConstants.resendIcon, "resend".tr(), 0));
                                              items.add(BtnBottomSheetModel(ImageConstants.cancelSendIcon, "send_cancel".tr(), 1));

                                              Get.bottomSheet(enterBottomSheetDuration: Duration(milliseconds: 100), exitBottomSheetDuration: Duration(milliseconds: 100),BtnBottomSheetWidget(
                                                btnItems: items,
                                                onTapItem: (menuIndex) async {
                                                  if(menuIndex == 0){
                                                    this.setState(() {
                                                      MessageModel messageModel = msgList[index];
                                                      msgList.removeAt(index);

                                                     // addChat(messageModel.contents ?? '', messageModel.type, messageModel);
                                                    });
                                                  }else {
                                                    this.setState(() {
                                                      msgList.removeAt(index);
                                                    });
                                                  }
                                                },
                                              ));
                                              return;
                                            }
                                            if (msgList[index].parent_id > 0) {
                                              List<MessageModel> list = msgList
                                                  .where((element) => element.id == msgList[index].parent_id)
                                                  .toList();
                                              if (list.isNotEmpty) {
                                                mainController.scrollToIndex(msgList.indexOf(list.first));
                                              }
                                            }
                                          },
                                          onReply: () {
                                            if (msgList[index].id == -1) return;
                                            setState(() {
                                              replyIdx = index;
                                            });
                                          },
                                          onLongPress: () {
                                            if (msgList[index].id == -1) return;
                                            List<BtnBottomSheetModel> items = [];
                                            if(msgList[index].type == eChatType.IMAGE.index) {
                                              items.add(BtnBottomSheetModel(
                                                  ImageConstants.imgDownload,
                                                  "save".tr(), 0));
                                            }else if(msgList[index].type != eChatType.AUDIO.index){
                                              items.add(BtnBottomSheetModel(
                                                  ImageConstants.copyIcon,
                                                  "copy".tr(), 0));
                                            }
                                            items.add(BtnBottomSheetModel(ImageConstants.replyIcon, "reply".tr(), 1));
                                            if(msgList[index].sender_id == Constants.user!.id)
                                              items.add(BtnBottomSheetModel(ImageConstants.deleteIcon, "delete".tr(), 2));

                                            Get.bottomSheet(enterBottomSheetDuration: Duration(milliseconds: 100), exitBottomSheetDuration: Duration(milliseconds: 100),BtnBottomSheetWidget(
                                              btnItems: items,
                                              onTapItem: (sheetIdx) async {
                                                if(sheetIdx == 0){
                                                  if(msgList[index].type == eChatType.IMAGE.index) {
                                                    List<String> images = (msgList[index].contents ?? '').split(",");
                                                    download(images, 0);
                                                  }else{
                                                    await Clipboard.setData(
                                                        ClipboardData(text: (msgList[index].contents ?? '')));
                                                  }
                                                }else if(sheetIdx == 1){
                                                  this.setState(() {
                                                    replyIdx = index;
                                                  });
                                                }else{
                                                  deleteChat(index);
                                                }
                                              },
                                            ));
                                          }),
                                    ),
                                  )
                              );
                            },
                          ),
                        );
  }

  Widget messagePreviewWidget()
  {
    return GestureDetector(
                            onTap: () {
                              mainController.scrollToIndex(0);
                            },
                            child: Container(
                              width: double.maxFinite,
                              margin: EdgeInsets.only(left: 10,right: 10),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: ColorConstants.white5Percent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  ImageUtils.ProfileImage(msgList.first.sender?.picture ?? "", 42, 42),
                                  const SizedBox(width: 10),
                                  AppText(
                                    text: msgList.first.sender?.name ?? '',
                                    fontSize: 13,
                                    color: ColorConstants.halfWhite,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: AppText(
                                      text: chatContent(msgList.first.contents ?? '', msgList.first.type ?? eChatType.NONE),
                                      fontSize: 14,
                                      maxLine: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Image.asset(
                                      ImageConstants.chatUnderWhite,
                                      height: 24,
                                      width: 24),
                                ],
                              ),
                            ),
                          );
  }


  @override
  Widget build(BuildContext context) {
    return PageLayout(
        onBack: onBackPressed,
        onTap: onHide,
        isKeyboardHide: false,
        isAvoidResize: false,
        isLoading: isLoading,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 64,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: onBackPressed,
                          child: Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.only(left: 10),
                              child: Center(
                                child: Image.asset(ImageConstants.backWhite, width: 24, height: 24, color: Colors.black,),
                              )
                          ),
                        ),
                        SizedBox(width: 10,),
                        //messageRoomNameWidget(),
                        AppText(text: '$clickTopic' ,fontSize: 15, fontWeight: FontWeight.w700,),
                        SizedBox(width: 10),                        
                      ],
                    ), 
                  ),
                  const Divider(height: 1,),


               //   isInit ?
                  Expanded(
                    child: Column(
                      children: [
                        messageDisplaySpaceWidget(),
                        if (bPreview) messagePreviewWidget(),
                          
                      ],
                    ),
                  ),
                  // : Expanded(
                  //   child: Center(
                  //     child: SizedBox(
                  //       child: Center(
                  //           child: CircularProgressIndicator(
                  //               color: ColorConstants.colorMain)
                  //       ),
                  //       height: 20.0,
                  //       width: 20.0,
                  //     ),
                  //   ),
                  // ),

                  if (replyIdx != -1) replyPreviewWidget(),
                  
                  inputBox(),
                ],
              ),

              Obx(() => (_isRecording.value && changedY != null && changedX != null && !_isRecordLock.value) ?
              Transform.translate(
                  offset: Offset(
                    changedX!.value,
                    changedY!.value - MediaQuery.of(context).padding.top,
                  ),
                  child: Container(
                    width: 30,
                    height: 30,
                    child: Image.asset(ImageConstants.micPressed, width: 30, height: 30),
                  )
              ) : Container()),

              Obx(() => (_isRecording.value && lockY != null && lockX != null && _isRecordLock.value) ?
              Transform.translate(
                  offset: Offset(
                    lockX!.value,
                    lockY!.value - MediaQuery.of(context).padding.top,
                  ),
                  child: IgnorePointer(
                    child: Container(
                      width: 30,
                      height: 30,
                      child: Image.asset(ImageConstants.micPressed, width: 30, height: 30),
                    ),
                  )
              ) : Container()),

              Obx(() => (_isRecording.value && changedY != null && changedX != null && !_isRecordLock.value) ?
              Transform.translate(
                  offset: Offset(
                    lockX!.value,
                    lockY!.value - MediaQuery.of(context).padding.top - 80,
                  ),
                  child: Container(
                    width: 30,
                    height: 60,
                    child: Image.asset(ImageConstants.audioLock, width: 30, height: 60),
                  )
              ) : Container())
            ],
          )
        )
    );
  }
}
