


import 'dart:convert';
import 'dart:io';


import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinodeflutter/Constants/Constants.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/utils.dart';

import '../../components/MyAssetPicker.dart';


class SettingAlarmScreen extends StatefulWidget {
  SettingAlarmScreen({super.key, });

  @override
  State<SettingAlarmScreen> createState() => _SettingAlarmScreen();
}

class _SettingAlarmScreen extends State<SettingAlarmScreen> {
  User user = Constants.user;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: ColorConstants.colorBg1,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            SizedBox(height: Get.height*0.07),
            Padding(
              padding:EdgeInsets.only(left: 15, right: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                          onTap: (){
                            Get.back();
                          },
                          child: Icon(Icons.arrow_back_ios, color:Colors.white)),

                      AppText(
                        text: "set_alarm".tr(),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )
                    ],
                  ),

                ],
              ),
            ),
            SizedBox(height: 30),


            SizedBox(height: 10),

            Padding(
              padding: EdgeInsets.only(left: 20,right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15,),

                  AppText(
                    text: "alarm_receive_setting".tr(),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 5,),

                  AppText(
                    text: "alarm_receive_setting_desc".tr(),
                    fontSize: 13,
                    color: ColorConstants.halfWhite,
                    fontWeight: FontWeight.w400,
                  ),

                  SizedBox(height: 5,),

                  Container(
                    color: ColorConstants.halfWhite,
                    height: 0.5,
                    width: double.maxFinite,
                  ),

                  SizedBox(height: 20,),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: "alarm_all_stop".tr(),
                                fontSize: 14,
                                textAlign: TextAlign.start,
                                fontWeight: FontWeight.w700,
                              ),

                              SizedBox(height: 5,),

                              AppText(
                                text: "alarm_all_stop_desc".tr(),
                                fontSize: 12,
                                textAlign: TextAlign.start,
                                color: ColorConstants.halfWhite,
                              )
                            ],
                          )
                      ),

                      FlutterSwitch(
                        value: user.setting.alarm,
                        width: 40,
                        height: 24,
                        activeColor: ColorConstants.colorMain,
                        activeToggleColor: ColorConstants.white,
                        inactiveColor: ColorConstants.textGry,
                        inactiveToggleColor: ColorConstants.white,
                        toggleSize: 20,
                        padding: 3,
                        onToggle: (newValue) async {
                          var response = await DioClient.setAlarm("notify_alarm", newValue);
                          setState(() {
                            user.setting = SettingModel.fromJson(response.data["result"]);
                          });
                        },
                      ),
                    ],
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 12),
                    height: 0.5,
                    color: ColorConstants.halfWhite,
                    width: double.maxFinite,
                  ),

                  SizedBox(height: 15,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: "reply_comment".tr(),
                                fontSize: 14,
                                textAlign: TextAlign.start,
                                fontWeight: FontWeight.w700,
                              ),

                              SizedBox(height: 5,),

                              AppText(
                                text: "alarm_comment_desc".tr(),
                                fontSize: 12,
                                textAlign: TextAlign.start,
                                color: ColorConstants.halfWhite,
                              )
                            ],
                          )
                      ),

                      FlutterSwitch(
                        value: user.setting.reply.state,
                        width: 40,
                        height: 24,
                        activeColor: ColorConstants.colorMain,
                        activeToggleColor: ColorConstants.white,
                        inactiveColor: ColorConstants.textGry,
                        inactiveToggleColor: ColorConstants.white,
                        toggleSize: 20,
                        padding: 3,
                        onToggle: (newValue) async {
                          var response = await DioClient.setAlarm("notify_reply", newValue);
                          setState(() {
                            user.setting = SettingModel.fromJson(response.data["result"]);
                          });
                        },
                      ),
                    ],
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 12),
                    height: 0.5,
                    color: ColorConstants.halfWhite,
                    width: double.maxFinite,
                  ),

                  SizedBox(height: 15,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: "like".tr(),
                                fontSize: 14,
                                textAlign: TextAlign.start,
                                fontWeight: FontWeight.w700,
                              ),

                              SizedBox(height: 5,),

                              AppText(
                                text: "alarm_like_desc".tr(),
                                fontSize: 12,
                                textAlign: TextAlign.start,
                                color: ColorConstants.halfWhite,
                              )
                            ],
                          )
                      ),

                      FlutterSwitch(
                        value: user.setting.like.state,
                        width: 40,
                        height: 24,
                        activeColor: ColorConstants.colorMain,
                        activeToggleColor: ColorConstants.white,
                        inactiveColor: ColorConstants.textGry,
                        inactiveToggleColor: ColorConstants.white,
                        toggleSize: 20,
                        padding: 3,
                        onToggle: (newValue) async {
                          var response = await DioClient.setAlarm("notify_like", newValue);
                          setState(() {
                            user.setting = SettingModel.fromJson(response.data["result"]);
                          });
                        },
                      ),
                    ],
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 12),
                    height: 0.5,
                    color: ColorConstants.halfWhite,
                    width: double.maxFinite,
                  ),

                  SizedBox(height: 15,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: "follow".tr(),
                                fontSize: 14,
                                textAlign: TextAlign.start,
                                fontWeight: FontWeight.w700,
                              ),

                              SizedBox(height: 5,),

                              AppText(
                                text: "alarm_follow_desc".tr(),
                                fontSize: 12,
                                textAlign: TextAlign.start,
                                color: ColorConstants.halfWhite,
                              )
                            ],
                          )
                      ),

                      FlutterSwitch(
                        value: user.setting.follow.state,
                        width: 40,
                        height: 24,
                        activeColor: ColorConstants.colorMain,
                        activeToggleColor: ColorConstants.white,
                        inactiveColor: ColorConstants.textGry,
                        inactiveToggleColor: ColorConstants.white,
                        toggleSize: 20,
                        padding: 3,
                        onToggle: (newValue) async {
                          var response = await DioClient.setAlarm("notify_follow", newValue);
                          setState(() {
                            user.setting = SettingModel.fromJson(response.data["result"]);
                          });
                        },
                      ),
                    ],
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 12),
                    height: 0.5,
                    color: ColorConstants.halfWhite,
                    width: double.maxFinite,
                  ),

                  SizedBox(height: 15,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: "alarm_dm_title".tr(),
                                fontSize: 14,
                                textAlign: TextAlign.start,
                                fontWeight: FontWeight.w700,
                              ),

                              SizedBox(height: 5,),

                              AppText(
                                text: "alarm_dm_desc".tr(),
                                fontSize: 12,
                                textAlign: TextAlign.start,
                                color: ColorConstants.halfWhite,
                              )
                            ],
                          )
                      ),

                      FlutterSwitch(
                        value: user.setting.dm.state,
                        width: 40,
                        height: 24,
                        activeColor: ColorConstants.colorMain,
                        activeToggleColor: ColorConstants.white,
                        inactiveColor: ColorConstants.textGry,
                        inactiveToggleColor: ColorConstants.white,
                        toggleSize: 20,
                        padding: 3,
                        onToggle: (newValue) async {
                          var response = await DioClient.setAlarm("notify_chat", newValue);
                          setState(() {
                            user.setting = SettingModel.fromJson(response.data["result"]);
                          });
                        },
                      ),
                    ],
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 12),
                    height: 0.5,
                    color: ColorConstants.halfWhite,
                    width: double.maxFinite,
                  ),

                  SizedBox(height: 15,),
                ],
              ),
            ),


          ],
        )
    );

  }
}