import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:image/image.dart' as img;
import 'package:get/get.dart' hide Trans;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:tinodeflutter/Constants/Constants.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:tinodeflutter/model/MessageModel.dart';
import 'package:tinodeflutter/model/userModel.dart';

import '../../Constants/ColorConstants.dart';
import '../../Constants/ImageConstants.dart';
import '../../Constants/ImageUtils.dart';
import '../../app_text.dart';
import '../../helpers/common_util.dart';
import '../widget/image_viewer.dart';

class ItemChatMsg extends StatelessWidget {
  List<UserModel> users;
  MessageModel messageData;
  //List<UnreadDto> unread;
  MessageModel? beforeMessage;
  MessageModel? nextMessage;
  String? parentNick;
  bool? bNewMsg;
  FlutterSoundPlayer? playerModule;

  final setState;
  final onProfile;
  final onDelete;
  final onTap;
  final onReply;
  final onLongPress;

  UserModel me;
  bool mine = true;
  bool isNewDate = false;
  bool paragraphStart = false;
  bool paragraphEnd = false;
  double profileHeight = 42.0;
  double profileWidth = 42.0;

  ItemChatMsg(
      {Key? key,
      required this.users,
      required this.messageData,
      //required this.unread,
      this.beforeMessage,
      this.nextMessage,
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
    //messageData.id: -1 실패, -2 전송중,

    bNewMsg ??= false;
    mine = messageData.sender_id == Constants.user.id;
    paragraphStart = chatTime2(messageData.created_at ?? '') !=
            chatTime2(beforeMessage?.created_at ?? '') ||
        messageData.sender_id != beforeMessage?.sender_id;
    paragraphEnd = chatTime2(messageData.created_at ?? '') !=
            chatTime2(nextMessage?.created_at ?? '') ||
        messageData.sender_id != nextMessage?.sender_id;
    profileHeight = paragraphStart ? 42.0 : 20.0;

    getUnreadCount(messageData);
    if (messageData.type == eChatType.VIDEO) {}
    // if (messageData.type == eChatType.AUDIO.index) {
    //   if ((messageData.audioTime ?? 0) == 0) {
    //     loadAudio();
    //   }
    // }
    if (beforeMessage != null) {
      try {
        DateTime beforeMessageDate =
            DateTime.parse(beforeMessage!.created_at ?? "");
        DateTime currentDate = DateTime.parse(messageData.created_at ?? "");
        if (beforeMessageDate.day != currentDate.day ||
            beforeMessageDate.month != currentDate.month ||
            beforeMessageDate.year != currentDate.year) {
          isNewDate = true;
        }
      } catch (e) {}
    } else {
      isNewDate = true;
    }
  }

  void getUnreadCount(dynamic messageData) {
    // print("chat id : ${messageData.id}, timetime : ${DateTime.now()}");
    // if (unread.isEmpty || (users.isEmpty)) return;
    // int count = 0;
    // for (var e in unread) {
    //   if (e.last_read_id != null &&
    //       users.map((e) => e.id).contains(e.user_id)) {
    //     if (e.last_read_id! < messageData.id) {
    //       count++;
    //     }
    //   }
    // }
    // messageData.unread_count = count;
  }

  Future<void> loadAudio() async {
    if (messageData.audioTime != null) {
      print("오디오 로드 실패");
      return;
    }
    print("오디오 로드");
    await playerModule?.closePlayer();
    await playerModule?.openPlayer();

    Duration duration = await playerModule?.startPlayer(
            fromURI: messageData.contents ?? '',
            codec: Codec.pcm16WAV,
            sampleRate: 44000,
            whenFinished: () {}) ??
        const Duration();
    messageData.audioTime = duration.inSeconds;
    await playerModule?.stopPlayer();
    await playerModule?.closePlayer();
    setState();
  }

  UserModel? getUser() {
    List<UserModel> list =
        users.where((element) => element.id == messageData.sender_id).toList();
    if (list.isEmpty && me.id == messageData.sender_id) {
      return me;
    } else if (messageData.sender != null) {
      return messageData.sender;
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
                  images: (messageData.contents ?? '').split(","),
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
        color: mine ? ColorConstants.colorMyMessage : ColorConstants.white,
        borderRadius: BorderRadius.circular(messageData.chat_idx == -1 ? 8 : 8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: AppText(
        text: messageData.unsended_at != null
            ? 'deleted_msg'.tr()
            : (messageData.contents ?? ''),
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.black,
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
    if (messageData.contents != null && messageData.contents!.isNotEmpty) {
      Map<String, dynamic> content = jsonDecode(messageData.contents ?? "{}");

      String systemType = content["type"];
      String msg = "";
      String users = "";
      print("system messageData : ${messageData.contents}");
      print("user nicks ${content['name']}");

      if (systemType == 'invite' && content['name'] == null) {
        msg = "과거에 생성된 시스템 초대 메시지 입니다.";
      } else {
        switch (systemType) {
          case "invite":
            if (content['name']?.length >= 2) {
              for (int i = 0; i < content['name']?.length; i++) {
                if (i == (content['name'].length - 1)) {
                  users += "${content['name'][i]}";
                } else {
                  users += "${content['name'][i]}, ";
                }
              }
            } else {
              users += "${content['name'][0]}";
            }
            msg = "${messageData.sender?.name}님이 $users을 그룹에 초대했습니다.";
            break;

          case "leave":
            msg = "${messageData.sender?.name}님이 그룹에서 나갔습니다.";
            break;

          case "update_expire":
            print("update-expire");
            msg =
                "${messageData.sender?.name}님이 메시지가 ${timerTranslation(content['minute'])} 후 자동 삭제되도록 설정했습니다.";
            break;

          default:
            msg = "";
            break;
        }
      }

      // msg = "${messageData.contents ?? ""} ${endText}";
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
    } else {
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
    if (messageData.created_at != null) {
      time = messageData.created_at!;
    } else if (messageData.unsended_at != null) {
      time = messageData.unsended_at!;
    }
    DateTime now = DateTime.now();
    try {
      DateTime createdTime = DateTime.parse(time);
      if (createdTime.year == now.year) {
        DateFormat formatter =
            DateFormat("dm_time_format".tr(), Constants.languageCode);
        String strToday = formatter.format(createdTime);
        return strToday;
      }
      DateFormat formatter =
          DateFormat("dm_time_format2".tr(), Constants.languageCode);
      String strToday = formatter.format(createdTime);
      return strToday;
    } catch (err) {
      print("1");
      return "";
    }
  }

  Widget imageTile(BuildContext context) {
    List<String> arr = (messageData.contents ?? '').split(",");
    int cnt =
        messageData.file.isNotEmpty ? messageData.file.length : arr.length;

    if (cnt == 1) {
      return Container(
        constraints: BoxConstraints(maxWidth: Get.width * 0.65),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                fullView(context, 0);
              },
              child: messageData.file.isNotEmpty
                  ? Image.file(
                      messageData.file[0],
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(imageUrl: arr[0], fit: BoxFit.cover),
            ),
            if (messageData.fileProgress != null &&
                messageData.totalProgress != null &&
                messageData.file != null)
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
                      percent: messageData.fileProgress!.toDouble() /
                          messageData.totalProgress!.toDouble(),
                      progressColor: Colors.white,
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    AppText(
                      text:
                          "${sizeStr(messageData.fileProgress!, messageData.totalProgress!)} / ${totalSizeStr(messageData.totalProgress!)}",
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
                  child: messageData.file.isNotEmpty
                      ? Image.file(
                          messageData.file[index],
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
          if (messageData.fileProgress != null &&
              messageData.totalProgress != null &&
              messageData.file != null)
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
                    percent: messageData.fileProgress!.toDouble() /
                        messageData.totalProgress!.toDouble(),
                    progressColor: Colors.white,
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  AppText(
                    text:
                        "${sizeStr(messageData.fileProgress!, messageData.totalProgress!)} / ${totalSizeStr(messageData.totalProgress!)}",
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
                      images: (messageData.contents ?? '').split(","),
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
              messageData.file.isNotEmpty
                  ? Image.file(
                      messageData.file[0],
                      fit: BoxFit.cover,
                    )
                  : (messageData.contents ?? '').split(",").length != 2
                      ? Container(color: Colors.black)
                      : CachedNetworkImage(
                          imageUrl: (messageData.contents ?? '').split(",")[1],
                          fit: BoxFit.cover,
                        ),
              if (messageData.fileProgress == null &&
                  messageData.totalProgress == null &&
                  messageData.file.isEmpty)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.asset(ImageConstants.playVideo,
                        width: 40, height: 40),
                  ),
                ),
              if (messageData.fileProgress != null &&
                  messageData.totalProgress != null &&
                  messageData.file != null)
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
                        percent: messageData.fileProgress!.toDouble() /
                            messageData.totalProgress!.toDouble(),
                        progressColor: Colors.white,
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      AppText(
                        text:
                            "${sizeStr(messageData.fileProgress!, messageData.totalProgress!)} / ${totalSizeStr(messageData.totalProgress!)}",
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
          messageData.isPlayAudio = false;
          setState();
        } else {
          await playerModule?.closePlayer();
          await playerModule?.openPlayer();

          await playerModule?.startPlayer(
                  fromURI: messageData.contents ?? '',
                  codec: Codec.pcm16WAV,
                  sampleRate: 44000,
                  whenFinished: () {
                    messageData.isPlayAudio = false;
                    setState();
                  }) ??
              const Duration();
          messageData.isPlayAudio = true;
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
                (messageData.isPlayAudio ?? false)
                    ? ImageConstants.pauseBtn
                    : ImageConstants.playBtn,
                width: 20,
                height: 20),
            SizedBox(
              width: 5,
            ),
            AppText(
              text:
                  "${pad2(Duration(seconds: messageData.audioTime ?? 0).inMinutes.remainder(60))}:${pad2((Duration(seconds: messageData.audioTime ?? 0).inSeconds.remainder(60)))}",
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget myReplyDisplayWidget() {
    return Visibility(
      visible: messageData.parent_id > 0 && messageData.chat_idx != -1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: "reply_from_me".tr(args: [parentNick ?? '']),
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: ColorConstants.halfBlack,
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 200),
            margin: const EdgeInsets.only(bottom: 4),
            child: AppText(
              text: messageData.parent_chat?.unsended_at != null
                  ? "deleted_msg".tr()
                  : chatContent(messageData.parent_chat?.contents ?? '',
                      (messageData.parent_chat?.type ?? eChatType.NONE)),
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }

  Widget opponentReplyDisplayWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: AppText(
            text: "reply_from_other".tr(
                args: [getUser()?.name ?? "unknown".tr(), parentNick ?? '']),
            fontSize: 10,
            color: ColorConstants.halfBlack,
          ),
        ),
        Container(
          constraints: const BoxConstraints(maxWidth: 200),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: AppText(
            text: chatContent(messageData.parent_chat?.contents ?? '',
                (messageData.parent_chat?.type ?? eChatType.NONE)),
            fontSize: 12,
          ),
        )
      ],
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
                  //         .format(messageData.created_at != null ||
                  //                 messageData.unsended_at != null
                  //             ? DateTime.parse(
                  //                 messageData.created_at ?? messageData.unsended_at ?? "")
                  //             : DateTime.now()),
                  text: getTime(),
                  color: Colors.black,
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
          messageData.type == eChatType.SYSTEM
              ? systemTile()
              : Stack(
                  children: [
                    Visibility(
                      // 내 채팅
                      visible: mine,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const SizedBox(height: 4),
                              //답장 표시
                              myReplyDisplayWidget(),

                              Row(
                                // 채팅 말풍선
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Visibility(
                                        visible:
                                            (messageData.unread_count ?? 0) > 0,
                                        child: AppText(
                                          text: '${messageData.unread_count}',
                                          color: ColorConstants.colorMain,
                                          fontSize: 10,
                                        ),
                                      ),
                                      if (paragraphEnd)
                                        messageData.id == -2
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
                                                    messageData.created_at ??
                                                        ''),
                                                fontSize: 10,
                                                color: ColorConstants.halfBlack,
                                              ),
                                    ],
                                  ),
                                  const SizedBox(width: 4),
                                  if (messageData.type == eChatType.TEXT)
                                    textTile()
                                  else if (messageData.type == eChatType.IMAGE)
                                    imageTile(context)
                                  else if (messageData.type == eChatType.VIDEO)
                                    videoTile(context)
                                  else if (messageData.type == eChatType.AUDIO)
                                    audioTile()
                                ],
                              ),
                            ],
                          ),
                          Visibility(
                            visible: messageData.id == -1,
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
                        // 상대방 채팅
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
                                          (messageData.sender?.picture ?? ''),
                                          profileWidth,
                                          profileHeight)),
                                ),
                                const SizedBox(width: 4),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    messageData.parent_id > 0 &&
                                            messageData.chat_idx != -1
                                        ? opponentReplyDisplayWidget()
                                        : Visibility(
                                            visible: paragraphStart,
                                            child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 6),
                                                child: InkWell(
                                                  onTap: onProfile,
                                                  child: AppText(
                                                    text: getUser()?.name ??
                                                        "unknown".tr(),
                                                    fontSize: 13,
                                                    color: ColorConstants
                                                        .halfBlack,
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
                                            if (messageData.type ==
                                                eChatType.TEXT)
                                              textTile()
                                            else if (messageData.type ==
                                                eChatType.IMAGE)
                                              imageTile(context)
                                            else if (messageData.type ==
                                                eChatType.VIDEO)
                                              videoTile(context)
                                            else if (messageData.type ==
                                                eChatType.AUDIO)
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
                                                  (messageData.unread_count ??
                                                          0) >
                                                      0,
                                              child: AppText(
                                                text:
                                                    '${messageData.unread_count}',
                                                color: ColorConstants.colorMain,
                                                fontSize: 10,
                                              ),
                                            ),
                                            if (paragraphEnd)
                                              AppText(
                                                text: chatTime3(
                                                    messageData.created_at ?? ''),
                                                fontSize: 10,
                                                color: ColorConstants.halfBlack,
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
