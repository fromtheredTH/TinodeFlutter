import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tinodeflutter/Constants/ColorConstants.dart';
import 'package:tinodeflutter/Constants/ImageUtils.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:tinodeflutter/model/MessageRoomModel.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/tinode/src/models/topic-description.dart';
import 'package:tinodeflutter/global/global.dart';

import '../../../Constants/Constants.dart';
import '../../../Constants/ImageConstants.dart';

class ItemChatRoom extends StatelessWidget {
  MessageRoomModel info;
  
  final onDelete;
  final onClick;
  final onLongPress;

  ItemChatRoom({Key? key, required this.info, this.onDelete, this.onClick, this.onLongPress})
      : super(key: key);

  String getRoomName(){
    if((info.name!="")) {
      return info.name ??"";
    }else{
      if((info.userList?.isEmpty ?? true)) {
        // if(info.is_group_room == 0 && info.personal_target != null){
        //   return info.personal_target?.nickname ?? "";
        // }
        if(info.is_my_room){
          return 'unknown'.tr();
        }else{
          return Constants.user.name;
        }
      }
    }

    return makeRoomName();
  }

  String makeRoomName() {
    List<String> list = info.userList?.map((e) => e.name ?? "").toList() ?? [];
    list.sort();
    String name = "";
    int cnt1 = 0;
    for(int i=0;i<list.length;i++){
      String nameTemp = name;
      if(nameTemp.isEmpty){
        nameTemp += list[i];
      }else{
        nameTemp += ",${list[i]}";
      }

      if(nameTemp.length >= 15){
        if(name.isEmpty){
          name = nameTemp;
          break;
        }else{
          break;
        }
      }else{
        name = nameTemp;
        cnt1++;
      }
    }
    int cnt2 = list.length - cnt1;
    if (cnt2> 0) {
      return "$name 외 $cnt2명";
    } else {
      return name;
    }
  }

  Widget makeRoomProfile(List<UserModel> users, double size) {
    if(users.length == 0){
      if(info.is_my_room == 1){
        return ImageUtils.ProfileImage(Constants.user.picture, size, size);
      }
      return ImageUtils.ProfileImage("", size, size);
    }else if(users.length == 1){
      return Container(
        width: size,
        height: size,
        child: ImageUtils.ProfileImage(users[0].picture ?? "", size, size),
      );
    }else if(users.length == 2){
      users.sort((a, b) => (a.name ?? "").compareTo(b.name ?? ""));
      List<UserModel> profileUsers = [users[0], users[1]];
      return Container(
        width: size,
        height: size/2 + 4,
        child: Stack(
          children: [
            Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: makeRoomProfile([profileUsers[0]], size/2 + 4)
            ),

            Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                child: makeRoomProfile([profileUsers[1]], size/2 + 4)
            ),
          ],
        ),
      );
    }else if(users.length == 3){
      users.sort((a, b) => (a.name ?? "").compareTo(b.name ?? ""));
      List<UserModel> profileUsers = [users[0], users[1], users[2]];
      return Container(
        width: size,
        height: size,
        child: Stack(
          children: [
            Positioned(
                top: 0,
                left: 0,
                child: makeRoomProfile([profileUsers[0]], size/2 + 4)
            ),

            Positioned(
                top: 0,
                right: 0,
                child: makeRoomProfile([profileUsers[1]], size/2 + 4)
            ),

            Align(
                alignment: Alignment.bottomCenter,
                child: makeRoomProfile([profileUsers[2]], size/2 + 4)
            ),
          ],
        ),
      );
    }else{
      users.sort((a, b) => (a.name ?? "").compareTo(b.name ?? ""));
      List<UserModel> profileUsers = [users[0], users[1], users[2], users[3]];
      return Container(
        width: size,
        height: size,
        child: Stack(
          children: [
            Positioned(
                top: 0,
                left: 0,
                child: makeRoomProfile([profileUsers[0]], size/2 + 4)
            ),

            Positioned(
                top: 0,
                right: 0,
                child: makeRoomProfile([profileUsers[1]], size/2 + 4)
            ),

            Positioned(
                bottom: 0,
                left: 0,
                child: makeRoomProfile([profileUsers[2]], size/2 + 4)
            ),

            Positioned(
                bottom: 0,
                right: 0,
                child: makeRoomProfile([profileUsers[3]], size/2 + 4)
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      onLongPress: onLongPress,
      child: Container(
          decoration: BoxDecoration(
              color: ColorConstants.white,
              border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
              ),),
        child: Column(
          children: [
            SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 10),
                makeRoomProfile(info.userList != null ?
                 (info.userList!.isNotEmpty ? 
                    info.userList! : [])
                    //(info.personal_target != null ? [info.personal_target!] : [])) 
                    : [],45),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          text: getRoomName(),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),

                        SizedBox(height: 5,),

                        AppText(
                          text: chatTime2(info.touched_at ?? ''),
                          fontSize: 11,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: AppText(
                              text: "서버 데이터 필요",//info.last_message?.unsended_at != null ? 'deleted_msg'.tr() :chatContent(info.last_message?.contents ?? 'new_room_msg'.tr(), eChatType.values[info.last_message?.type ?? 0]),
                              fontSize: 12,
                              color: Colors.grey,
                              maxLine: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ),

                        SizedBox(height: 5,),

                        if(info.unread_count > 0)
                          Container(
                            padding: EdgeInsets.only(left: 5,right: 5,top: 2,bottom: 2),
                            decoration: BoxDecoration(color: Color(0xffeb5757), borderRadius: BorderRadius.circular(50)),
                            child: Center(
                              child: AppText(
                                text: info.unread_count > 99 ? "+99" : "${info.unread_count}",
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),

                  ],
                )
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
