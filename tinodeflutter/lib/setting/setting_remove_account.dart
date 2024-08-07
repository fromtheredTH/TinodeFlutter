import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/components/widget/app_button.dart';
import 'package:tinodeflutter/components/widget/loading_widget.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/utils.dart';

import '../../components/MyAssetPicker.dart';

class SettingRemoveAccountScreen extends StatefulWidget {
  SettingRemoveAccountScreen({
    super.key,
  });

  @override
  State<SettingRemoveAccountScreen> createState() =>
      _SettingRemoveAccountScreen();
}

class _SettingRemoveAccountScreen extends State<SettingRemoveAccountScreen> {
  TextEditingController msgController = TextEditingController();
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
  }

  String reason = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstants.backgroundGrey,
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
                              Icon(Icons.arrow_back_ios, color: Colors.black)),
                      AppText(
                        text: "remove_account".tr(),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
                child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 25),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: "resignup_limit_title".tr(),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),

                          SizedBox(
                            height: 15,
                          ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: "·",
                                fontSize: 13,
                                color: ColorConstants.halfBlack,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: AppText(
                                  text: "resignup_limit_desc_1".tr(),
                                  fontSize: 13,
                                  color: ColorConstants.halfBlack,
                                ),
                              )
                            ],
                          ),
                          // SizedBox(height: 5,),
                          // Row(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     AppText(
                          //       text: "·",
                          //       fontSize: 13,
                          //       color: ColorConstants.halfBlack,
                          //     ),

                          //     SizedBox(width: 5,),

                          //     Expanded(child: AppText(
                          //       text: "resignup_limit_desc_2".tr(),
                          //       fontSize: 13,
                          //       color: ColorConstants.halfWhite,
                          //     ),)
                          //   ],
                          // ),
                          // SizedBox(height: 5,),
                          // Row(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     AppText(
                          //       text: "·",
                          //       fontSize: 13,
                          //       color: ColorConstants.halfWhite,
                          //     ),

                          //     SizedBox(width: 5,),

                          //     Expanded(child: AppText(
                          //       text: "resignup_limit_desc_3".tr(),
                          //       fontSize: 13,
                          //       color: ColorConstants.halfWhite,
                          //     ),)
                          //   ],
                          // ),
                          // SizedBox(height: 5,),
                          // Row(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     AppText(
                          //       text: "·",
                          //       fontSize: 13,
                          //       color: ColorConstants.halfWhite,
                          //     ),

                          //     SizedBox(width: 5,),

                          //     Expanded(child: AppText(
                          //       text: "resignup_limit_desc_4".tr(),
                          //       fontSize: 13,
                          //       color: ColorConstants.halfWhite,
                          //     ),)
                          //   ],
                          // ),

                          SizedBox(
                            height: 25,
                          ),

                          AppText(
                            text: "remove_account_info".tr(),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),

                          SizedBox(
                            height: 15,
                          ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: "·",
                                fontSize: 13,
                                color: ColorConstants.halfBlack,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: AppText(
                                  text: "remove_account_info_desc_1".tr(),
                                  fontSize: 13,
                                  color: ColorConstants.halfBlack,
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: "·",
                                fontSize: 13,
                                color: ColorConstants.halfBlack,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: AppText(
                                  text: "remove_account_info_desc_2".tr(),
                                  fontSize: 13,
                                  color: ColorConstants.halfBlack,
                                ),
                              )
                            ],
                          ),

                          SizedBox(
                            height: 25,
                          ),

                          AppText(
                            text: "why_delete_account".tr(),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),

                          SizedBox(
                            height: 15,
                          ),

                          TextField(
                            maxLines: 5,
                            minLines: 5,
                            maxLength: 500,
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: FontConstants.AppFont,
                                fontSize: 13),
                            controller: msgController,
                            decoration: InputDecoration(
                                counterText: "",
                                hintText: "input".tr(),
                                hintStyle: TextStyle(
                                    color: ColorConstants.halfBlack,
                                    fontSize: 13,
                                    fontFamily: FontConstants.AppFont,
                                    fontWeight: FontWeight.w400),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  gapPadding: 5,
                                  borderSide: BorderSide(
                                      color: ColorConstants.halfBlack,
                                      width: 0.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  gapPadding: 5,
                                  borderSide: BorderSide(
                                      color: ColorConstants.halfBlack,
                                      width: 0.0),
                                ),
                                contentPadding: const EdgeInsets.all(10)),
                            onChanged: (text) {
                              setState(() {
                                reason = text;
                              });
                            },
                          ),

                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isSelected = !isSelected;
                              });
                            },
                            child: Container(
                              height: 40,
                              margin: EdgeInsets.only(bottom: 5, top: 15),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  isSelected
                                      ? Icon(
                                          Icons.check_box_rounded,
                                          size: 24,
                                          color: ColorConstants.colorMain,
                                        )
                                      : Icon(
                                          Icons.check_box_outline_blank_rounded,
                                          size: 24,
                                          color: ColorConstants.halfBlack,
                                        ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: AppText(
                                      text: "delete_account_agree".tr(),
                                      color: isSelected
                                          ? ColorConstants.colorMain
                                          : ColorConstants.halfBlack,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ]),
              ),
            )),
            Container(
              margin: EdgeInsets.only(bottom: 15, left: 15, right: 15),
              child: AppButton(
                  disabled: !isSelected,
                  disableColor: ColorConstants.textGry,
                  margin: 0,
                  text: "send".tr(),
                  onTap: () async {
                    LoadingWidget();
                    // ChatRoomUtils.deleteAllRooms();
                    // Constants.localChatRooms.clear();
                    //await DioClient.deleteFCM(gPushKey);
                    await FirebaseMessaging.instance.deleteToken();
                    var response = await tinode_global.deleteCurrentUser(true);
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.remove('login_type');
                    prefs.remove('basic_id');
                    prefs.remove('basic_pw');
                    prefs.remove('token');
                    prefs.remove('url_encoded_token');
                    //  var response = await DioClient.postDeleteAccount(reason);
                    // if (response.statusCode == 200) {
                    //   showToast("회원 탈퇴하셨습니다.");
                    // } else {
                    //   showToast("탈퇴 실패. 고객센터 문의 필요");
                    // }
                    //Get.offAll(SplashPage());
                    try {
                      await FirebaseAuth.instance.signOut(); // 토큰 삭제
                      if (isLoading) Get.back();
                    } catch (err) {
                      print("err $err");
                      if (isLoading) Get.back();
                    }
                  }),
            )
          ],
        ));
  }
}
