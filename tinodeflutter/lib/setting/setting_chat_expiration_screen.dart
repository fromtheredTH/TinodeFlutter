import 'dart:convert';
import 'dart:io';


import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinodeflutter/Constants/Constants.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/tinode/src/topic.dart';
import 'package:tinodeflutter/tinode/tinode.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/utils.dart';

import '../../components/MyAssetPicker.dart';


enum eExpirationState {
  IFINITY,
  ONE_HOUR,
  ONE_DAY,
  ONE_WEEK,
  ONE_MONTH,
}


class SettingChatExpirationeScreen extends StatefulWidget {
  Topic roomTopic;
  Tinode tinode;
  
  SettingChatExpirationeScreen({super.key, required this.tinode, required this.roomTopic });

  @override
  State<SettingChatExpirationeScreen> createState() =>
      _SettingChatExpirationeScreen();
}

class _SettingChatExpirationeScreen
    extends State<SettingChatExpirationeScreen> {
  User user = Constants.user;
  int selectedIndex = 0;

  late Topic roomTopic;
  late Tinode tinode;
  String toastMsg ="";
  Future<void> setChatRemoveTimer(int range) async {
    setState(() {
      selectedIndex = range - 1;
    });
    try{
     //var response = DioClient.postUpdateChatExpire(roomDto.id, selectedIndex);
    //var response =await DioClient.postUpdateChatExpire(roomDto.id, 101); // test
    switch(selectedIndex)
    {
      case 0:
            toastMsg = "비활성으로 변경되었습니다.";
      break;
      case 1:
            toastMsg = "1시간으로 변경되었습니다.";
      break;
      case 2:
            toastMsg = "1일로 변경되었습니다.";
      break;
      case 3:
            toastMsg = "7일로 변경되었습니다.";
      break;
      case 4:
            toastMsg = "30일로로 변경되었습니다.";
      break;
      default:        
      break;
    }
    showToast("$toastMsg");
    }
    catch(err){
        showToast('Fail to change remove timer');
    }
    // showToast('caht timer response : ${response}');
  }


  initTimerData() {
    print("min : ${roomTopic.chat_expire_minute}");
    // showToast("${roomDto.chat_expire_minute}");
    switch (roomTopic.chat_expire_minute) {
      case 60000000:
        selectedIndex = 0;
      case 60:
        selectedIndex = 1;
      case 1440:
        selectedIndex = 2;
      case 10080:
        selectedIndex = 3;
      case 43200:
        selectedIndex = 4;
      default:
        break;
    }
  }

  @override
  void initState() {
    tinode = widget.tinode;
    roomTopic = widget.roomTopic;
    setState(() {
      initTimerData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstants.colorBg1,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            SizedBox(height: Get.height * 0.07),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child:
                              Icon(Icons.arrow_back_ios, color: Colors.white)),
                      AppText(
                        text: "auto_remove_time_chat".tr(),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 15,
                  ),

                  // AppText(
                  //   text: "alarm_receive_setting".tr(),
                  //   fontSize: 14,
                  //   fontWeight: FontWeight.w700,
                  // ),
                  // SizedBox(height: 5,),

                  AppText(
                    text: "auto_remove_time_chat_desc".tr(),
                    fontSize: 13,
                    color: ColorConstants.halfWhite,
                    fontWeight: FontWeight.w400,
                  ),

                  SizedBox(
                    height: 5,
                  ),
                  // 회색 라인
                  // Container(
                  //   color: ColorConstants.halfWhite,
                  //   height: 0.5,
                  //   width: double.maxFinite,
                  // ),

                  SizedBox(
                    height: 20,
                  ),

                  GestureDetector(
                    onTap: () {
                      setChatRemoveTimer(1);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          selectedIndex == 0
                              ? ImageConstants.radioButtonGreen
                              : ImageConstants.radioButton,
                          height: Get.height * 0.024,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        AppText(
                          text: "비활성",
                          color: selectedIndex == 0
                              ? ColorConstants.colorMain
                              : ColorConstants.white,
                          fontSize: 14,
                        )
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 15,
                  ),

                  GestureDetector(
                    onTap: () {
                      setChatRemoveTimer(2);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          selectedIndex == 1
                              ? ImageConstants.radioButtonGreen
                              : ImageConstants.radioButton,
                          height: Get.height * 0.024,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        AppText(
                          text: "1시간",
                          color: selectedIndex == 1
                              ? ColorConstants.colorMain
                              : ColorConstants.white,
                          fontSize: 14,
                        )
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 15,
                  ),

                  GestureDetector(
                    onTap: () {
                      setChatRemoveTimer(3);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          selectedIndex == 2
                              ? ImageConstants.radioButtonGreen
                              : ImageConstants.radioButton,
                          height: Get.height * 0.024,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        AppText(
                          text: "1일",
                          color: selectedIndex == 2
                              ? ColorConstants.colorMain
                              : ColorConstants.white,
                          fontSize: 14,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),

                  GestureDetector(
                    onTap: () {
                      setChatRemoveTimer(4);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          selectedIndex == 3
                              ? ImageConstants.radioButtonGreen
                              : ImageConstants.radioButton,
                          height: Get.height * 0.024,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        AppText(
                          text: "7일",
                          color: selectedIndex == 3
                              ? ColorConstants.colorMain
                              : ColorConstants.white,
                          fontSize: 14,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),

                  GestureDetector(
                    onTap: () {
                      setChatRemoveTimer(5);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          selectedIndex == 4
                              ? ImageConstants.radioButtonGreen
                              : ImageConstants.radioButton,
                          height: Get.height * 0.024,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        AppText(
                          text: "30일",
                          color: selectedIndex == 4
                              ? ColorConstants.colorMain
                              : ColorConstants.white,
                          fontSize: 14,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
