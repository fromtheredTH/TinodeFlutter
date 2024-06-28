import 'dart:typed_data';
import 'dart:convert';

import 'package:app/Constants/ColorConstants.dart';
import 'package:app/Constants/Constants.dart';
import 'package:app/Constants/ImageConstants.dart';
import 'package:app/Constants/ImageUtils.dart';
import 'package:app/models/dto/user_dto.dart';
import 'package:image/image.dart' as img;
import 'package:app/global/global.dart';
import 'package:get/get.dart' hide Trans;
import 'package:app/models/dto/unread_dto.dart';
import 'package:app/pages/components/fucus_detector.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app/global/app_colors.dart';
import 'package:app/helpers/common_util.dart';
import 'package:app/helpers/transition.dart';
import 'package:app/models/dto/chat_msg_dto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:app/write_log.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../Constants/ColorConstants.dart';
import '../../Constants/ImageConstants.dart';
import '../../Constants/ImageUtils.dart';
import '../../app_text.dart';
import '../../helpers/common_util.dart';
import '../image_viewer.dart';

class ItemChatMsg extends StatelessWidget {
  List<UserDto> users;
  ChatMsgDto info;
  List<UnreadDto> unread;
  ChatMsgDto? before;
  ChatMsgDto? next;
  String? parentNick;
  bool? bNewMsg;
  final setState;
  final onProfile;
  final onDelete;
  final onTap;
  final onReply;
  final onLongPress;

  UserDto me;
  bool mine = true;
  bool isNewDate = false;
  bool paragraphStart = false;
  bool paragraphEnd = false;
  double profileHeight = 42.0;
  double profileWidth = 42.0;

  ItemChatMsg(
      {Key? key,
      required this.users,
      required this.info,
      required this.unread,
      this.before,
      this.next,
      this.parentNick,
      this.bNewMsg,
      required this.me,
      required this.setState,
      required this.playerModule,
      required this.onProfile,
      required this.onDelete,
      required this.onTap,
      required this.onReply,
      required this.onLongPress})
      : super(key: key) {
    //info.id: -1 실패, -2 전송중,

    bNewMsg ??= false;
    mine = info.sender_id == gCurrentId;
    paragraphStart = chatTime2(info.created_at ?? '') !=
            chatTime2(before?.created_at ?? '') ||
        info.sender_id != before?.sender_id;
    paragraphEnd =
        chatTime2(info.created_at ?? '') != chatTime2(next?.created_at ?? '') ||
            info.sender_id != next?.sender_id;
    profileHeight = paragraphStart ? 42.0 : 20.0;

    getUnreadCount(info);
    if (info.type == eChatType.VIDEO.index) {}
    // if (info.type == eChatType.AUDIO.index) {
    //   if ((info.audioTime ?? 0) == 0) {
    //     loadAudio();
    //   }
    // }
    if (before != null) {
      try {
        DateTime beforeDate = DateTime.parse(before!.created_at ?? "");
        DateTime currentDate = DateTime.parse(info.created_at ?? "");
        if (beforeDate.day != currentDate.day ||
            beforeDate.month != currentDate.month ||
            beforeDate.year != currentDate.year) {
          isNewDate = true;
        }
      } catch (e) {}
    } else {
      isNewDate = true;
    }
  }

  void getUnreadCount(dynamic info) {
    // print("chat id : ${info.id}, timetime : ${DateTime.now()}");
    if (unread.isEmpty || (users.isEmpty)) return;
    int count = 0;
    for (var e in unread) {
      if (e.last_read_id != null &&
          users.map((e) => e.id).contains(e.user_id)) {
        if (e.last_read_id! < info.id) {
          count++;
        }
      }
    }
    info.unread_count = count;
    // WriteLog.renderingEndTime = DateTime.now();
    // WriteLog.write("unread chat id : ${info.id}, timetime : ${DateTime.now()}\n ",fileName: 'getUnreadCountFunc.txt');
    // WriteLog.write("unread chat id : ${info.id}, timetime : ${DateTime.now()}\n ",fileName: 'AllInOne.txt');
    // WriteLog.write(' clientRenderingTime chat id : ${info.id} : ${WriteLog.TimeDifferenceClientRendering()} \n',fileName: 'clitent_Rendering_Span.txt');
    // WriteLog.write(' clientRenderingTime chat id : ${info.id} : ${WriteLog.TimeDifferenceClientRendering()} \n',fileName: 'AllInOne.txt');
    // WriteLog.write(' overall_Span time: ${WriteLog.TimeDifferenceOverall()} \n',fileName: 'overall_Span.txt');
    // WriteLog.write(' overall_Span time: ${WriteLog.TimeDifferenceOverall()} \n',fileName: 'AllInOne.txt');
  }

  Future<void> loadAudio() async {
    if (info.audioTime != null) {
      print("오디오 로드 실패");
      return;
    }
    print("오디오 로드");
    await playerModule?.closePlayer();
    await playerModule?.openPlayer();

    Duration duration = await playerModule?.startPlayer(
            fromURI: info.contents ?? '',
            codec: Codec.pcm16WAV,
            sampleRate: 44000,
            whenFinished: () {}) ??
        const Duration();
    info.audioTime = duration.inSeconds;
    await playerModule?.stopPlayer();
    await playerModule?.closePlayer();
    setState();
  }

  UserDto? getUser() {
    List<UserDto> list =
        users.where((element) => element.id == info.sender_id).toList();
    if (list.isEmpty && me.id == info.sender_id) {
      return me;
    } else if (info.sender != null) {
      return info.sender;
    } else if (list.isEmpty) {
      return null;
    }
    return list.first;
  }

  void fullView(BuildContext context, int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ImageViewer(
                  images: (info.contents ?? '').split(","),
                  selected: index,
                  isVideo: false,
                  user: getUser(),
                ))).then((value) {
      if (value == "delete") {
        onDelete();
      }
    });
  }

  Widget textTile() {
    return Container(
      constraints: BoxConstraints(maxWidth: Get.width * 0.65),
      decoration: BoxDecoration(
        color:
            mine ? ColorConstants.colorMyMessage : ColorConstants.white5Percent,
        borderRadius: BorderRadius.circular(info.chat_idx == -1 ? 8 : 8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: AppText(
        text: info.unsended_at != null
            ? 'deleted_msg'.tr()
            : (info.contents ?? ''),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  String timerTranslation(int expire_minute) {
    String minute_tr = "";
    switch (expire_minute) {
      case 60000000:
        minute_tr = "비활성";
        break;
      case 60:
        minute_tr = "1시간";
        break;
      case 1440:
        minute_tr = "1일";
        break;
      case 10080:
        minute_tr = "7일";
        break;
      case 43200:
        minute_tr = "30일";
        break;
      default:
        break;
    }
    return minute_tr;
  }

  Widget systemTile() {
    if(info.contents != null && info.contents!.isNotEmpty) {
      Map<String, dynamic> content = jsonDecode(info.contents ?? "{}");
      

      String systemType = content["type"];
      String msg = "";
      String users = "";
      print("system info : ${info.contents}");
      print("user nicks ${content['user_nicknames']}");

      if (systemType=='invite' && content['user_nicknames'] == null) {
        msg = "과거에 생성된 시스템 초대 메시지 입니다.";
      } else {
        switch (systemType) {
          case "invite":
            if (content['user_nicknames']?.length >= 2) {
              for (int i = 0; i < content['user_nicknames']?.length; i++) {
                if (i == (content['user_nicknames'].length - 1)) {
                  users += "${content['user_nicknames'][i]}";
                } else {
                  users += "${content['user_nicknames'][i]}, ";
                }
              }
            } else {
              users += "${content['user_nicknames'][0]}";
            }
            msg = "${info.sender?.nickname}님이 $users을 그룹에 초대했습니다.";
            break;

          case "leave":
            msg = "${info.sender?.nickname}님이 그룹에서 나갔습니다.";
            break;

          case "update_expire":
            print("update-expire");
            msg =
                "${info.sender?.nickname}님이 메시지가 ${timerTranslation(content['minute'])} 후 자동 삭제되도록 설정했습니다.";
            break;

          default:
            msg = "";
            break;
        }
      }

      // msg = "${info.contents ?? ""} ${endText}";
      return Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: AppText(
            text: msg,
            fontSize: 10,
            textAlign: TextAlign.center,
            color: ColorConstants.white,
          ),
        ),
      );
    }
    else {
      return Container();
    }


  }

  double getImageSize(int cnt, index) {
    if (cnt <= 2 || cnt == 4) {
      return Get.width * 0.65 / 2 - 4;
    } else if (cnt == 3 || cnt == 6 || cnt == 9) {
      return Get.width * 0.65 / 3 - 4;
    } else if (cnt == 5 || cnt == 7) {
      return index <= 2 ? Get.width * 0.65 / 3 - 4 : Get.width * 0.65 / 2 - 4;
    } else if (cnt == 8 || cnt == 10) {
      return index <= 5 ? Get.width * 0.65 / 3 - 4 : Get.width * 0.65 / 2 - 4;
    }
    return 0;
  }

  String getTime() {
    String time = "";
    if( info.created_at != null){
      time = info.created_at!;
    }else if (info.unsended_at != null){
      time = info.unsended_at!;
    }
    DateTime now = DateTime.now();
    DateTime createdTime = DateTime.parse(time);
    if(createdTime.year == now.year) {
      DateFormat formatter = DateFormat("dm_time_format".tr(), Constants.languageCode);
      String strToday = formatter.format(createdTime);
      return strToday;
    }
    DateFormat formatter = DateFormat("dm_time_format2".tr(), Constants.languageCode);
    String strToday = formatter.format(createdTime);
    return strToday;
  }

  Widget imageTile(BuildContext context) {
    List<String> arr = (info.contents ?? '').split(",");
    int cnt = info.file.isNotEmpty ? info.file.length : arr.length;

    if (cnt == 1) {
      return Container(
        constraints: BoxConstraints(maxWidth: Get.width * 0.65),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                fullView(context, 0);
              },
              child: info.file.isNotEmpty
                  ? Image.file(
                      info.file[0],
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(imageUrl: arr[0], fit: BoxFit.cover),
            ),
            if (info.fileProgress != null &&
                info.totalProgress != null &&
                info.file != null)
              Positioned.fill(
                  child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularPercentIndicator(
                      radius: 12.0,
                      lineWidth: 1.0,
                      percent: info.fileProgress!.toDouble() /
                          info.totalProgress!.toDouble(),
                      progressColor: Colors.white,
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    AppText(
                      text:
                          "${sizeStr(info.fileProgress!, info.totalProgress!)} / ${totalSizeStr(info.totalProgress!)}",
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ],
                )),
              )),
          ],
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(maxWidth: Get.width * 0.65),
      child: Stack(
        children: [
          Wrap(
            alignment: WrapAlignment.start,
            runSpacing: 4,
            spacing: 4,
            children: [
              ...List.generate(cnt, (index) {
                return GestureDetector(
                  onTap: () {
                    fullView(context, index);
                  },
                  child: info.file.isNotEmpty
                      ? Image.file(
                          info.file[index],
                          width: getImageSize(cnt, index),
                          height: getImageSize(cnt, index),
                          fit: BoxFit.cover,
                        )
                      : CachedNetworkImage(
                          imageUrl: arr[index],
                          fit: BoxFit.cover,
                          width: getImageSize(cnt, index),
                          height: getImageSize(cnt, index),
                        ),
                );
              })
            ],
          ),
          if (info.fileProgress != null &&
              info.totalProgress != null &&
              info.file != null)
            Positioned.fill(
                child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularPercentIndicator(
                    radius: 12.0,
                    lineWidth: 1.0,
                    percent: info.fileProgress!.toDouble() /
                        info.totalProgress!.toDouble(),
                    progressColor: Colors.white,
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  AppText(
                    text:
                        "${sizeStr(info.fileProgress!, info.totalProgress!)} / ${totalSizeStr(info.totalProgress!)}",
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ],
              )),
            )),
        ],
      ),
    );
  }

  Widget videoTile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImageViewer(
                      images: (info.contents ?? '').split(","),
                      selected: 0,
                      isVideo: true,
                      user: getUser(),
                    ))).then((value) {
          if (value == "delete") {
            onDelete();
          }
        });
      },
      child: Container(
          constraints: BoxConstraints(maxWidth: 240),
          child: Stack(
            children: [
              info.file.isNotEmpty
                  ? Image.file(
                      info.file[0],
                      fit: BoxFit.cover,
                    )
                  : (info.contents ?? '').split(",").length != 2
                      ? Container(color: Colors.black)
                      : CachedNetworkImage(
                          imageUrl: (info.contents ?? '').split(",")[1],
                          fit: BoxFit.cover,
                        ),
              if (info.fileProgress == null &&
                  info.totalProgress == null &&
                  info.file.isEmpty)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.asset(ImageConstants.playVideo,
                        width: 40, height: 40),
                  ),
                ),
              if (info.fileProgress != null &&
                  info.totalProgress != null &&
                  info.file != null)
                Positioned.fill(
                    child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularPercentIndicator(
                        radius: 12.0,
                        lineWidth: 1.0,
                        percent: info.fileProgress!.toDouble() /
                            info.totalProgress!.toDouble(),
                        progressColor: Colors.white,
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      AppText(
                        text:
                            "${sizeStr(info.fileProgress!, info.totalProgress!)} / ${totalSizeStr(info.totalProgress!)}",
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ],
                  )),
                )),
            ],
          )),
    );
  }

  Widget audioTile() {
    return GestureDetector(
      onTap: () async {
        if (playerModule?.isPlaying ?? false) {
          await playerModule?.stopPlayer();
          info.isPlayAudio = false;
          setState();
        } else {
          await playerModule?.closePlayer();
          await playerModule?.openPlayer();

          await playerModule?.startPlayer(
                  fromURI: info.contents ?? '',
                  codec: Codec.pcm16WAV,
                  sampleRate: 44000,
                  whenFinished: () {
                    info.isPlayAudio = false;
                    setState();
                  }) ??
              const Duration();
          info.isPlayAudio = true;
          setState();
        }
      },
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: mine
              ? ColorConstants.colorOptionBrown
              : ColorConstants.white5Percent,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
                (info.isPlayAudio ?? false)
                    ? ImageConstants.pauseBtn
                    : ImageConstants.playBtn,
                width: 20,
                height: 20),
            SizedBox(
              width: 5,
            ),
            AppText(
              text:
                  "${pad2(Duration(seconds: info.audioTime ?? 0).inMinutes.remainder(60))}:${pad2((Duration(seconds: info.audioTime ?? 0).inSeconds.remainder(60)))}",
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      // onHorizontalDragEnd: (details) {
      //   if ((details.primaryVelocity ?? 0) > 20) {
      //     onReply();
      //   }
      // },
      child: Column(
        children: [
          if (isNewDate)
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: Center(
                child: AppText(
                  // text:
                  //     DateFormat("dm_time_format".tr(), Constants.languageCode)
                  //         .format(info.created_at != null ||
                  //                 info.unsended_at != null
                  //             ? DateTime.parse(
                  //                 info.created_at ?? info.unsended_at ?? "")
                  //             : DateTime.now()),
                  text: getTime(),
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          if (bNewMsg!)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Container(
                          height: 0.5, color: ColorConstants.colorMain)),
                  const SizedBox(width: 20),
                  AppText(
                    text: 'new_msg'.tr(),
                    fontSize: 10,
                    color: ColorConstants.colorMain,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                      child: Container(
                          height: 0.51, color: ColorConstants.colorMain)),
                ],
              ),
            ),
          info.type == 5
              ? systemTile()
              : Stack(
                  children: [
                    Visibility(
                      visible: mine,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const SizedBox(height: 4),
                              Visibility(
                                visible:
                                    info.parent_id > 0 && info.chat_idx != -1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      text: "reply_from_me"
                                          .tr(args: [parentNick ?? '']),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: ColorConstants.halfWhite,
                                    ),
                                    Container(
                                      constraints:
                                          const BoxConstraints(maxWidth: 200),
                                      margin: const EdgeInsets.only(bottom: 4),
                                      child: AppText(
                                        text: info.parent_chat?.unsended_at !=
                                                null
                                            ? "deleted_msg".tr()
                                            : chatContent(
                                                info.parent_chat?.contents ??
                                                    '',
                                                info.parent_chat?.type ?? 0),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Visibility(
                                        visible: (info.unread_count ?? 0) > 0,
                                        child: AppText(
                                          text: '${info.unread_count}',
                                          color: ColorConstants.colorMain,
                                          fontSize: 10,
                                        ),
                                      ),
                                      if (paragraphEnd)
                                        info.id == -2
                                            ? SizedBox(
                                                width: 12,
                                                height: 12,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color:
                                                      ColorConstants.colorMain,
                                                ),
                                              )
                                            : AppText(
                                                text: chatTime3(
                                                    info.created_at ?? ''),
                                                fontSize: 10,
                                                color: ColorConstants.halfWhite,
                                              ),
                                    ],
                                  ),
                                  const SizedBox(width: 4),
                                  if (info.type == eChatType.TEXT.index)
                                    textTile()
                                  else if (info.type == eChatType.IMAGE.index)
                                    imageTile(context)
                                  else if (info.type == eChatType.VIDEO.index)
                                    videoTile(context)
                                  else if (info.type == eChatType.AUDIO.index)
                                    audioTile()
                                ],
                              ),
                            ],
                          ),
                          Visibility(
                            visible: info.id == -1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Image.asset(
                                ImageConstants.chatFail,
                                width: 20,
                                height: 20,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Visibility(
                        visible: !mine,
                        child: Column(
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Opacity(
                                  opacity: paragraphStart ? 1 : 0,
                                  child: InkWell(
                                      onTap: onProfile,
                                      child: ImageUtils.ProfileImage(
                                          (info.sender?.picture ?? ''),
                                          profileWidth,
                                          profileHeight)),
                                ),
                                const SizedBox(width: 4),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    info.parent_id > 0 && info.chat_idx != -1
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 6),
                                                child: AppText(
                                                  text: "reply_from_other".tr(
                                                      args: [
                                                        getUser()?.nickname ??
                                                            "unknown".tr(),
                                                        parentNick ?? ''
                                                      ]),
                                                  fontSize: 10,
                                                  color:
                                                      ColorConstants.halfWhite,
                                                ),
                                              ),
                                              Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 200),
                                                margin: const EdgeInsets.only(
                                                    bottom: 4),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                child: AppText(
                                                  text: chatContent(
                                                      info.parent_chat
                                                              ?.contents ??
                                                          '',
                                                      info.parent_chat?.type ??
                                                          0),
                                                  fontSize: 12,
                                                ),
                                              )
                                            ],
                                          )
                                        : Visibility(
                                            visible: paragraphStart,
                                            child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 6),
                                                child: InkWell(
                                                  onTap: onProfile,
                                                  child: AppText(
                                                    text: getUser()?.nickname ??
                                                        "unknown".tr(),
                                                    fontSize: 13,
                                                    color: ColorConstants
                                                        .halfWhite,
                                                  ),
                                                )),
                                          ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (info.type ==
                                                eChatType.TEXT.index)
                                              textTile()
                                            else if (info.type ==
                                                eChatType.IMAGE.index)
                                              imageTile(context)
                                            else if (info.type ==
                                                eChatType.VIDEO.index)
                                              videoTile(context)
                                            else if (info.type ==
                                                eChatType.AUDIO.index)
                                              audioTile()
                                          ],
                                        ),
                                        const SizedBox(width: 4),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Visibility(
                                              visible:
                                                  (info.unread_count ?? 0) > 0,
                                              child: AppText(
                                                text: '${info.unread_count}',
                                                color: ColorConstants.colorMain,
                                                fontSize: 10,
                                              ),
                                            ),
                                            if (paragraphEnd)
                                              AppText(
                                                text: chatTime3(
                                                    info.created_at ?? ''),
                                                fontSize: 10,
                                                color: ColorConstants.halfWhite,
                                              ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          ],
                        )),
                  ],
                ),
        ],
      ),
    );
  }
}
