import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:tinodeflutter/Constants/ColorConstants.dart';
import 'package:tinodeflutter/Constants/Constants.dart';
import 'package:tinodeflutter/Constants/ImageConstants.dart';
import 'package:tinodeflutter/Constants/ImageUtils.dart';
import 'package:tinodeflutter/Constants/utils.dart';
import 'package:tinodeflutter/Screen/setting_list_screen.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/components/BottomProfileWidget.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/tinode/tinode.dart';
import 'package:tinodeflutter/login.dart';

class ProfileScreen extends StatefulWidget {
  Tinode tinode;
  User user;

  ProfileScreen({super.key, required this.tinode, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Tinode tinode;
  late Topic roomTopic;
  late Topic me;
  late User user;

  @override
  void initState() {
    super.initState();
    tinode = widget.tinode;
    user = widget.user;
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

  Widget QrWidget() {
    return GestureDetector(
      onTap: () async {
        if (Constants.userQrCode != null) {
          double currentBright = await ScreenBrightness().current;
          await ScreenBrightness().setScreenBrightness(1.0);
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            barrierDismissible: true,
            //바깥 영역 터치시 닫을지 여부 결정
            builder: ((context) {
              return Dialog(
                backgroundColor: ColorConstants.colorBg1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Container(
                  width: Get.width * 0.6,
                  height: Get.width * 0.4 + 180,
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      AppText(
                        text: "my_qr_code",
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: double.maxFinite,
                        height: 0.5,
                        color: ColorConstants.halfWhite,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SvgPicture.asset(
                        ImageConstants.appLogo,
                        height: 20,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Image.memory(
                        Constants.userQrCode!,
                        width: Get.width * 0.4,
                        height: Get.width * 0.4,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(
                              text: "https://jade-chat.com/${user.nickname}"));
                          Utils.showToast("qr_copy_complete");
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ImageUtils.setImage(
                                ImageConstants.copyIcon, 18, 18),
                            AppText(
                              text: "qr_copy",
                              fontSize: 14,
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              );
            }),
          ).then((value) async {
            await ScreenBrightness().setScreenBrightness(currentBright);
          });
        }
      },
      child: ImageUtils.setImage(ImageConstants.qr, 25, 25),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 24, 197, 160),
        resizeToAvoidBottomInset: true,
        body: Column(children: [
          SizedBox(height: Get.height * 0.07),
          Padding(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // if(user.id!=Constants.user.id)
                    GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Icon(Icons.arrow_back_ios, color: Colors.white)),

                    AppText(
                      text: user.id == tinode.userId //Constants.user.id
                          ? "my_page"
                          : user.id != 0
                              ? user.nickname
                              : "deleted_account",
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    )
                  ],
                ),
                user.id == 1 // Constants.user.id
                    ? Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.bottomSheet(
                                  enterBottomSheetDuration:
                                      Duration(milliseconds: 100),
                                  exitBottomSheetDuration:
                                      Duration(milliseconds: 100),
                                  BottomProfileWidget(
                                      user: user,
                                      setting: () {
                                        Get.to(SettingListScreen(
                                          onChangedUser: (user) {
                                            setState(() {
                                              this.user = user;
                                            });
                                          },
                                        ));
                                      },
                                      logout: () async {
                                        // await DioClient.deleteFCM(
                                        //     gPushKey);
                                        // await FirebaseMessaging.instance
                                        //     .deleteToken();
                                        // await FirebaseAuth.instance
                                        //     .signOut();
                                        // ChatRoomUtils.deleteAllRooms();
                                        // PostingUtils.deleteAllPosts();
                                        // DiscoverUtils.deleteAllPosts();
                                        // Constants.localChatRooms.clear();
                                        // Get.offAll(SplashPage());
                                        //Get.offAll(()=>Login(title: "티노드"));
                                      }));
                            },
                            child: SvgPicture.asset(ImageConstants.moreIcon),
                          )
                        ],
                      )
                    : Container()
              ],
            ),
          ),
          SizedBox(height: Get.height * 0.02),
          Center(
            child: ImageUtils.ProfileImage(user.picture, 150, 150),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: AppText(text: user.name),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(text: tinode.userId),
              SizedBox(width: 20,),
              QrWidget(),
            ],
          )),
          SizedBox(
            height: 10,
          ),
        ]));
  }
}
