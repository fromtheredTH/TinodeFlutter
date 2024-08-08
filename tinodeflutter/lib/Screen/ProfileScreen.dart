import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;

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
import 'package:tinodeflutter/Screen/SplashScreen.dart';
import 'package:tinodeflutter/Screen/setting_list_screen.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/components/widget/BottomProfileWidget.dart';
import 'package:tinodeflutter/components/widget/BtnBottomSheetWidget.dart';
import 'package:tinodeflutter/components/widget/GalleryBottomSheet.dart';
import 'package:tinodeflutter/components/MyAssetPicker.dart';
import 'package:tinodeflutter/components/widget/image_viewer.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:tinodeflutter/model/btn_bottom_sheet_model.dart';
import 'package:tinodeflutter/global/DioClient.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/page/base/base_state.dart';
import 'package:tinodeflutter/page/base/page_layout.dart';
import 'package:tinodeflutter/tinode/tinode.dart';
import 'package:tinodeflutter/Screen/Login/login.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:tinodeflutter/Screen/Login/login.dart' as LoignScreen;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';


class ProfileScreen extends StatefulWidget {
  UserModel user;

  ProfileScreen({super.key,  required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends BaseState<ProfileScreen> {
  late Topic roomTopic;
  late Topic _meTopic;
  //late TopicSubscription userTopicSub;
  late UserModel user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _meTopic = tinode_global.getMeTopic();

  }
    @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    return super.didChangeAppLifecycleState(state);
  }
  

  Future<void> _delFriend(String userid) async {
    var data = await tinode_global.friMeta(userid, 'del');
  }

  Future<void> _addFriend(String userid) async {
    try {
      var data = await tinode_global.friMeta(userid, 'add');
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
          sendImage(f);
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
        sendImage(f);
        Constants.cachingKey = DateTime.now().millisecondsSinceEpoch.toString();
        //getUserInfo();
      }
    });
  }

   Future<void> sendImage(File file) async {
    try {
        // Message 객체 생성

        // 메시지를 발행하여 서버에 전송
        var result = await DioClient.postUploadFile(file.path);

        if (result.data['ctrl']['code'] == 200)
          print("${result.data['ctrl']['params']['url'].toString()}");
        String extension="";
        String urlPath = result.data['ctrl']['params']['url'];
        List<String> parts = urlPath.split('.');
        if (parts.length > 1) {
          extension = parts.last;
          print(extension); 
        }
        Map<String,dynamic> photoData = {
        'data' : 'DEL',
        'ref' : urlPath,
        'type' : extension
        };
         Map<String,dynamic> publicData = {
        'photo' : photoData,
        };
       
        SetParams setParams = SetParams(
        desc: TopicDescription(
          public: publicData, 
          ),
      );
      
        List<String> imageData = [urlPath];
        Map<String, List<String>> extra = {"attachments": imageData};

      var response = await _meTopic.setMeta(setParams, extra: extra);

      print('이미지가 성공적으로 서버에 전송되었습니다.');
      updateUserInfo();
      showToast('변경완료');
    } catch (err) {
      print("image send err: $err");
      showToast('300MB까지 가능합니다.');
    }
  }

  void updateUserInfo() async
  {
    await Constants.getMyInfo(_meTopic);
    setState(() {
      user = Constants.user;
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
              backgroundColor: Colors.grey,
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
                      text: "my_qr_code".tr(),
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
                        Utils.showToast("qr_copy_complete".tr());
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageUtils.setImage(ImageConstants.copyIcon, 18, 18, color:  Colors.black),
                          AppText(
                            text: "qr_copy".tr(),
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
      child: Icon(Icons.qr_code,  size: 25, color: Colors.black,),
      // ImageUtils.setImage(ImageConstants.qr, 25, 25,),
    );
  }

  Widget _profileWidget()
  {
    return Stack(
            children: [
              Center(
                child:GestureDetector(
                  onTap: ()=>{
                     Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ImageViewer(
                                    fileUrlList: [user.picture],//(messageData.contents ?? '').split(","),
                                    selected: 0,
                                    isVideo: false,
                                    user: user,
                                    isProfile: true,
                                  ))).then((value) {
                      
                      }),
                  },
                   child: ImageUtils.ProfileImage(
                     user.picture!="" ? (user.picture.contains('https://') ? user.picture :  changePathToLink(user.picture)) : "",
                     100, 100),
                ),
               ),
              if (user.id == Constants.user.id)
                Positioned(
                  bottom: -10, // 프로필 이미지와 겹치도록 조정
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(0, -10), // 위로 약간 이동
                      child: GestureDetector(
                        onTap: () async {
            if (await _promptPermissionSetting()) {
              List<BtnBottomSheetModel> items = [];
              items.add(BtnBottomSheetModel(
                  ImageConstants.cameraIcon, "camera".tr(), 0));
              items.add(BtnBottomSheetModel(
                  ImageConstants.albumIcon, "gallery".tr(), 1));
              items.add(BtnBottomSheetModel(ImageConstants.deleteIcon,
                  "current_profile_delete".tr(), 2));

              Get.bottomSheet(
                  enterBottomSheetDuration: Duration(milliseconds: 100),
                  exitBottomSheetDuration: Duration(milliseconds: 100),
                  BtnBottomSheetWidget(
                    btnItems: items,
                    onTapItem: (sheetIdx) async {
                      if (sheetIdx == 0) {
                        AssetEntity? assets =
                            await MyAssetPicker.pickCamera(context, false);
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
                                          sendText: "profile_change".tr(),
                                          onlyImage: true,
                                          isProfile: true,
                                          onTapSend: (results) {
                                            procAssetsWithGallery(results);
                                          },
                                        ));
                              });
                        }
                      } else {
                        // delete profile image
                        await CachedNetworkImage.evictFromCache(
                            user.picture ?? "");
                        //  getUserInfo();
                      }
                    },
                  ));
            }
          },
                        child: Container(
                          width: 30, // 컨테이너 크기 조정
                          height: 30,
                          // decoration: BoxDecoration(
                          //   color: Colors.white, // 배경색 추가
                          //   shape: BoxShape.circle, // 원형 모양
                          //   border: Border.all(color: Colors.grey, width: 1), // 테두리 추가
                          // ),
                          child: Center(
                            child: ImageUtils.setImage(ImageConstants.editProfile, 25, 25),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  statusBarColor: Colors.white, // 상태바 배경색을 흰색으로 설정
  statusBarBrightness: Brightness.light, // iOS에서 상태바 콘텐츠를 어둡게 (검은색)
  statusBarIconBrightness: Brightness.dark, // Android에서 상태바 아이콘을 어둡게 (검은색)
));
    return  Scaffold(
        backgroundColor: Colors.white,
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
                   if(user.id!=Constants.user.id)
                    GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Icon(Icons.arrow_back_ios, color: Colors.black)),

                    AppText(
                      text: user.id == tinode_global.userId //Constants.user.id
                          ? "my_page".tr()
                          : user.id != 0
                              ? user.name
                              : "deleted_account".tr(),
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
                                          onChangedUser: (user) {
                                            setState(() {
                                              this.user = user;
                                            });
                                          },
                                        ));
                                      },
                                      logout: () async {
                                        Utils.showDialogWidget(context);
                                        tinode_global.jadechatLogout(); //ws 연결은 유지
                                        await FirebaseMessaging.instance.deleteToken();                                         
                                        SharedPreferences prefs = await SharedPreferences.getInstance();
                                        prefs.remove('login_type');
                                        prefs.remove('basic_id');
                                        prefs.remove('basic_pw');
                                        prefs.remove('token');
                                        prefs.remove('url_encoded_token');
                                        if(FirebaseAuth.instance!=null ) await FirebaseAuth.instance.signOut();
                                        //Get.offAll(()=>LoignScreen.Login());
                                        Get.offAll(SplashPage());
                                        // await DioClient.deleteFCM(
                                        //     gPushKey);
                                       
                                        // ChatRoomUtils.deleteAllRooms();
                                        // PostingUtils.deleteAllPosts();
                                        // DiscoverUtils.deleteAllPosts();
                                        // Constants.localChatRooms.clear();
                                        //Get.offAll(()=>Login(title: "티노드"));
                                      }));
                            },
                            child:  ImageUtils.setImage(ImageConstants.profileSetting, 28, 28, color: Colors.black), // SvgPicture.asset(ImageConstants.moreIcon,),
                          )
                        ],
                      )
                    : Container()
              ],
            ),
          ),
          SizedBox(height: Get.height * 0.02),
          _profileWidget(),

          SizedBox(
            height: 10,
          ),
         Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
               AppText(text: "이름 :", fontSize: 16, fontWeight: FontWeight.w700,),
               SizedBox(width: 10,),
               AppText(text: user.name, fontSize: 16, fontWeight: FontWeight.w700,),
          ]),
          
          SizedBox(
            height: 10,
          ),
          Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               AppText(text: "JadeChat ID :", fontSize: 13, fontWeight: FontWeight.w700,),
               SizedBox(width: 10,),
               AppText(text: user.searchId, fontSize: 13, fontWeight: FontWeight.w700,),
               SizedBox(width: 15,),
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
                
               // AppText(text: "멤버십 정보", fontSize: 25,),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   children: [
                //     AppText(text: 'level :'),
                //     SizedBox(
                //       width: 10,
                //     ),
                //     AppText(text: Constants.user.membership['level'].toString()),
                //   ],
                // ),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                      AppText(
                    text: "서비스 이용기간 :",
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    //color: ColorConstants.white,
                    ),
                       const SizedBox(
                        width: 10,
                      ),
              
                    if (Constants.user.membership != null &&  Constants.user.membership!['level'] != 0)
                      AppText(
                        text: "${Constants.user.membership!['endat']}",
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: ColorConstants.colorMain,
                      )
                  ],
                )
              ]),
            )
        ]));
  }
}
