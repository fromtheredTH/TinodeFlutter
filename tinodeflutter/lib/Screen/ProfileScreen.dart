import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:tinodeflutter/Constants/ColorConstants.dart';
import 'package:tinodeflutter/Constants/Constants.dart';
import 'package:tinodeflutter/Constants/ImageConstants.dart';
import 'package:tinodeflutter/Constants/ImageUtils.dart';
import 'package:tinodeflutter/Constants/utils.dart';
import 'package:tinodeflutter/Screen/setting_list_screen.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/components/widget/BottomProfileWidget.dart';
import 'package:tinodeflutter/components/widget/BtnBottomSheetWidget.dart';
import 'package:tinodeflutter/components/widget/GalleryBottomSheet.dart';
import 'package:tinodeflutter/components/MyAssetPicker.dart';
import 'package:tinodeflutter/model/btn_bottom_sheet_model.dart';
import 'package:tinodeflutter/global/DioClient.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/tinode/tinode.dart';
import 'package:tinodeflutter/Screen/Login/login.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:tinodeflutter/Screen/Login/login.dart' as LoignScreen;

class ProfileScreen extends StatefulWidget {
  Tinode tinode;
  UserModel user;

  ProfileScreen({super.key, required this.tinode, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Tinode tinode;
  late Topic roomTopic;
  late Topic me;
  //late TopicSubscription userTopicSub;
  late UserModel user;

  @override
  void initState() {
    super.initState();
    tinode = widget.tinode;
    user = widget.user;
  }

  Future<void> _delFriend(String userid) async {
    var data = await tinode.friMeta(userid, 'del');
  }

  Future<void> _addFriend(String userid) async {
    try {
      var data = await tinode.friMeta(userid, 'add');
      print("ddd");
      if (data.code == 200) {
        setState(() {
          user.isFreind = true;
        });
      }
    } catch (err) {
      print("add freind : $err");
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

  Future<void> procAssets(List<AssetEntity>? assets) async {
    if (assets != null) {
      await Future.forEach<AssetEntity>(assets, (file) async {
        File? f = await file.originFile;
        if (file.type == AssetType.image && f != null) {
          var response = await DioClient.updateUserProfile(f, null, null, null);
          Constants.cachingKey =
              DateTime.now().millisecondsSinceEpoch.toString();
          // getUserInfo();
        }
      });
    }
  }

  Future<void> procAssetsWithGallery(List<Medium> assets) async {
    await Future.forEach<Medium>(assets, (file) async {
      File? f = await file.getFile();
      if (file.mediumType == MediumType.image && f != null) {
        var response = await DioClient.updateUserProfile(f, null, null, null);
        Constants.cachingKey = DateTime.now().millisecondsSinceEpoch.toString();
        //getUserInfo();
      }
    });
  }

  Widget QrWidget() {
    return GestureDetector(
      onTap: () async {
        double currentBright = await ScreenBrightness().current;
        await ScreenBrightness().setScreenBrightness(1.0);
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          barrierDismissible: true,
          //바깥 영역 터치시 닫을지 여부 결정
          builder: ((context) {
            return Dialog(
              backgroundColor: Colors.grey[300],
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
                    // Image.memory(
                    //   Constants.userQrCode!,
                    //   width: Get.width * 0.4,
                    //   height: Get.width * 0.4,
                    // ),
                    QrImageView(
                      data: 'https://jade-chat.com/${user.name}',
                      version: QrVersions.auto,
                      size: Get.width * 0.4,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(
                            text: "https://jade-chat.com/${user.name}"));
                        Utils.showToast("qr_copy_complete");
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageUtils.setImage(ImageConstants.copyIcon, 18, 18),
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
      },
      child: ImageUtils.setImage(ImageConstants.qr, 25, 25),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey,
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
                              ? user.name
                              : "deleted_account",
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    )
                  ],
                ),
                user.id == Constants.user.id
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
                                          tinode: tinode,
                                          onChangedUser: (user) {
                                            setState(() {
                                              this.user = user;
                                            });
                                          },
                                        ));
                                      },
                                      logout: () async {
                                        tinode.logout();
                                        Get.offAll(()=>LoignScreen.Login());
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
          Stack(
            children: [
              Center(
                child: ImageUtils.ProfileImage(user.picture ?? "", 150, 150),
              ),
              if (user.id == Constants.user.id)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () async {
                      if (await _promptPermissionSetting()) {
                        List<BtnBottomSheetModel> items = [];
                        items.add(BtnBottomSheetModel(
                            ImageConstants.cameraIcon, "camera", 0));
                        items.add(BtnBottomSheetModel(
                            ImageConstants.albumIcon, "gallery", 1));
                        items.add(BtnBottomSheetModel(ImageConstants.deleteIcon,
                            "current_profile_delete", 2));

                        Get.bottomSheet(
                            enterBottomSheetDuration:
                                Duration(milliseconds: 100),
                            exitBottomSheetDuration:
                                Duration(milliseconds: 100),
                            BtnBottomSheetWidget(
                              btnItems: items,
                              onTapItem: (sheetIdx) async {
                                if (sheetIdx == 0) {
                                  AssetEntity? assets =
                                      await MyAssetPicker.pickCamera(
                                          context, false);
                                  if (assets != null) {
                                    procAssets([assets]);
                                  }
                                } else if (sheetIdx == 1) {
                                  if (await _promptPermissionSetting()) {
                                    showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        isDismissible: true,
                                        backgroundColor: Colors.transparent,
                                        constraints: BoxConstraints(
                                          minHeight: 0.8,
                                          maxHeight: Get.height * 0.95,
                                        ),
                                        builder: (BuildContext context) {
                                          return DraggableScrollableSheet(
                                              initialChildSize: 0.5,
                                              minChildSize: 0.4,
                                              maxChildSize: 0.9,
                                              expand: false,
                                              builder: (_, controller) =>
                                                  GalleryBottomSheet(
                                                    controller: controller,
                                                    limitCnt: 1,
                                                    sendText: "profile_change",
                                                    onlyImage: true,
                                                    onTapSend: (results) {
                                                      procAssetsWithGallery(
                                                          results);
                                                    },
                                                  ));
                                        });
                                  }
                                } else {
                                  // delete profile image
                                  // var response = await DioClient.updateUserProfile( null, null, true, null);
                                  await CachedNetworkImage.evictFromCache(
                                      user.picture ?? "");
                                  //  getUserInfo();
                                }
                              },
                            ));
                      }
                    },
                    child:
                        ImageUtils.setImage(ImageConstants.editProfile, 20, 20),
                  ),
                )
            ],
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
              SizedBox(
                width: 20,
              ),
              if(user.id == Constants.user.id) QrWidget(),
            ],
          )),
          SizedBox(
            height: 10,
          ),
          if (user.id != Constants.user.id && !user.isFreind)
            GestureDetector(
              onTap: () {
                _addFriend(user.id);
              },
              child: Container(
                  width: 120,
                  height: 40,
                  color: Colors.white,
                  child: AppText(
                    text: "친구추가",
                    textAlign: TextAlign.center,
                  )),
            )
          else if(user.isFreind)
            AppText(
              text: "친구입니다",
              textAlign: TextAlign.center,
            ),
          if (user.id == Constants.user.id)
            Container(
              alignment: Alignment.center,
              child: Column(children: [
                
                AppText(text: "멤버십 정보", fontSize: 25,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppText(text: 'level :'),
                    SizedBox(
                      width: 10,
                    ),
                    AppText(text: Constants.user.membership['level'].toString()),
                  ],
                ),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppText(text: 'end at :'),
                    SizedBox(
                      width: 10,
                    ),
                    AppText(text: Constants.user.membership['endat'].toString()),
                  ],
                )
              ]),
            )
        ]));
  }
}
