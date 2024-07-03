


import 'dart:convert';
import 'dart:io';


import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:tinodeflutter/Constants/Constants.dart';
import 'package:tinodeflutter/Constants/ImageUtils.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/model/userModel.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/utils.dart';


class SettingListScreen extends StatefulWidget {
  SettingListScreen({super.key, required this.onChangedUser });
  Function(User) onChangedUser;

  @override
  State<SettingListScreen> createState() => _SettingListScreen();
}

class _SettingListScreen extends State<SettingListScreen> {



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
                        text: "setting".tr(),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )
                    ],
                  ),

                ],
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(left: 20,right: 20),
                  child: Column(
                      children: [
                        // GestureDetector(
                        //   onTap: (){
                        //     Get.to(SettingAccountScreen(onChangedUser: (user){
                        //       widget.onChangedUser(user);
                        //     },));
                        //   },
                        //   child:Container(
                        //     height: 30,
                        //     color: Colors.transparent,
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       crossAxisAlignment: CrossAxisAlignment.center,
                        //       children: [
                        //         Row(
                        //           crossAxisAlignment: CrossAxisAlignment.center,
                        //           children: [
                        //             ImageUtils.setImage(ImageConstants.settingAccount, 20, 20),
                        //             SizedBox(width: 5,),
                        //             AppText(
                        //               text: "account".tr(),
                        //               fontSize: 14,
                        //             )
                        //           ],
                        //         ),

                        //         Icon(Icons.arrow_forward_ios_rounded, color: ColorConstants.white, size: 14,)
                        //       ],
                        //     ),
                        //   ),
                        // ),

                        Container(
                          margin: EdgeInsets.only(top: 15, bottom: 25),
                          height: 0.5,
                          color: ColorConstants.halfWhite,
                        ),

                        // GestureDetector(
                        //   onTap: (){
                        //     Get.to(PurchaseScreen());
                        //   },
                        //   child: Container(
                        //     color: Colors.transparent,
                        //     height: 30,
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       crossAxisAlignment: CrossAxisAlignment.center,
                        //       children: [
                        //         Row(
                        //           crossAxisAlignment: CrossAxisAlignment.center,
                        //           children: [
                        //             ImageUtils.setImage(ImageConstants.settingSecurity, 20, 20),
                        //             SizedBox(width: 5,),
                        //             AppText(
                        //               text: "purchase_service".tr(),
                        //               fontSize: 14,
                        //             )
                        //           ],
                        //         ),

                        //         Icon(Icons.arrow_forward_ios_rounded, color: ColorConstants.white, size: 14,)
                        //       ],
                        //     ),
                        //   )
                        // ),

                        // Container(
                        //   margin: EdgeInsets.only(top: 15, bottom: 25),
                        //   height: 0.5,
                        //   color: ColorConstants.halfWhite,
                        // ),

                        // GestureDetector(
                        //   onTap: (){
                        //     Get.to(ProfileEditScreen(onRefreshUser: (user){
                        //       widget.onChangedUser(user);
                        //     },));
                        //   },
                        //   child: Container(
                        //     height: 30,
                        //     color: Colors.transparent,
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       crossAxisAlignment: CrossAxisAlignment.center,
                        //       children: [
                        //         Row(
                        //           crossAxisAlignment: CrossAxisAlignment.center,
                        //           children: [
                        //             ImageUtils.setImage(ImageConstants.settingProfile, 20, 20),
                        //             SizedBox(width: 5,),
                        //             AppText(
                        //               text: "profile".tr(),
                        //               fontSize: 14,
                        //             )
                        //           ],
                        //         ),

                        //         Icon(Icons.arrow_forward_ios_rounded, color: ColorConstants.white, size: 14,)
                        //       ],
                        //     ),
                        //   )
                        // ),

                        Container(
                          margin: EdgeInsets.only(top: 15, bottom: 25),
                          height: 0.5,
                          color: ColorConstants.halfWhite,
                        ),

                        GestureDetector(
                          onTap: (){
                            if(Constants.languageCode == "ko") {
                              Utils.urlLaunch("https://jade-chat.com/terms");
                            }else{
                              Utils.urlLaunch("https://jade-chat.com/terms");
                            }
                          },
                          child: Container(
                            height: 30,
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ImageUtils.setImage(ImageConstants.settingTerms, 20, 20),
                                    SizedBox(width: 5,),
                                    AppText(
                                      text: "terms".tr(),
                                      fontSize: 14,
                                    )
                                  ],
                                ),

                                Icon(Icons.arrow_forward_ios_rounded, color: ColorConstants.white, size: 14,)
                              ],
                            ),
                          )
                        ),

                        // Container(
                        //   margin: EdgeInsets.only(top: 15, bottom: 25),
                        //   height: 0.5,
                        //   color: ColorConstants.halfWhite,
                        // ),

                        // GestureDetector(
                        //   onTap: (){
                        //     Get.to(SettingAlarmScreen());
                        //   },
                        //   child: Container(
                        //     height: 30,
                        //     color: Colors.transparent,
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       crossAxisAlignment: CrossAxisAlignment.center,
                        //       children: [
                        //         Row(
                        //           crossAxisAlignment: CrossAxisAlignment.center,
                        //           children: [
                        //             ImageUtils.setImage(ImageConstants.settingAlarm, 20, 20),
                        //             SizedBox(width: 5,),
                        //             AppText(
                        //               text: "set_alarm".tr(),
                        //               fontSize: 14,
                        //             )
                        //           ],
                        //         ),

                        //         Icon(Icons.arrow_forward_ios_rounded, color: ColorConstants.white, size: 14,)
                        //       ],
                        //     ),
                        //   )
                        // ),

                        Container(
                          margin: EdgeInsets.only(top: 15, bottom: 25),
                          height: 0.5,
                          color: ColorConstants.halfWhite,
                        ),

                        // GestureDetector(
                        //   onTap: (){
                        //     Get.to(SettingBlockScreen());
                        //   },
                        //   child: Container(
                        //     height: 30,
                        //     color: Colors.transparent,
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       crossAxisAlignment: CrossAxisAlignment.center,
                        //       children: [
                        //         Row(
                        //           crossAxisAlignment: CrossAxisAlignment.center,
                        //           children: [
                        //             ImageUtils.setImage(ImageConstants.settingBlock, 20, 20),
                        //             SizedBox(width: 5,),
                        //             AppText(
                        //               text: "block_manage".tr(),
                        //               fontSize: 14,
                        //             )
                        //           ],
                        //         ),

                        //         Icon(Icons.arrow_forward_ios_rounded, color: ColorConstants.white, size: 14,)
                        //       ],
                        //     ),
                        //   )
                        // ),

                        Container(
                          margin: EdgeInsets.only(top: 15, bottom: 25),
                          height: 0.5,
                          color: ColorConstants.halfWhite,
                        ),

                        // GestureDetector(
                        //   onTap: (){
                        //     Get.to(SettingMessageScreen());
                        //   },
                        //   child: Container(
                        //     color: Colors.transparent,
                        //     height: 30,
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       crossAxisAlignment: CrossAxisAlignment.center,
                        //       children: [
                        //         Row(
                        //           crossAxisAlignment: CrossAxisAlignment.center,
                        //           children: [
                        //             ImageUtils.setImage(ImageConstants.settingMsg, 20, 20),
                        //             SizedBox(width: 5,),
                        //             AppText(
                        //               text: "message_manage".tr(),
                        //               fontSize: 14,
                        //             )
                        //           ],
                        //         ),

                        //         Icon(Icons.arrow_forward_ios_rounded, color: ColorConstants.white, size: 14,)
                        //       ],
                        //     ),
                        //   )
                        // ),

                        Container(
                          margin: EdgeInsets.only(top: 15, bottom: 25),
                          height: 0.5,
                          color: ColorConstants.halfWhite,
                        ),

                        // GestureDetector(
                        //   onTap: (){
                        //     Get.to(SettingQuestionScreen());
                        //   },
                        //   child: Container(
                        //     height: 30,
                        //     color: Colors.transparent,
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       crossAxisAlignment: CrossAxisAlignment.center,
                        //       children: [
                        //         Row(
                        //           crossAxisAlignment: CrossAxisAlignment.center,
                        //           children: [
                        //             ImageUtils.setImage(ImageConstants.settingQuestion, 20, 20),
                        //             SizedBox(width: 5,),
                        //             AppText(
                        //               text: "question".tr(),
                        //               fontSize: 14,
                        //             )
                        //           ],
                        //         ),

                        //         Icon(Icons.arrow_forward_ios_rounded, color: ColorConstants.white, size: 14,)
                        //       ],
                        //     ),
                        //   )
                        // ),

                      
                        Container(
                          margin: EdgeInsets.only(top: 15, bottom: 25),
                          height: 0.5,
                          color: ColorConstants.halfWhite,
                        ),

                        GestureDetector(
                          onTap: (){

                          },
                          child: Container(
                            height: 30,
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ImageUtils.setImage(ImageConstants.settingVersion, 20, 20),
                                    SizedBox(width: 5,),
                                    AppText(
                                      text: "version_info".tr(),
                                      fontSize: 14,
                                    )
                                  ],
                                ),

                                AppText(
                                  text: Constants.versionName,
                                  fontSize: 14,
                                )
                              ],
                            ),
                          )
                        ),

                        SizedBox(height: 25,)
                      ]
                  ),
                )
              ),
            ),
          ],
        )
    );

  }
}