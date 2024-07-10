


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
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/components/widget/BlockUserListItemWidget.dart';
import 'package:tinodeflutter/components/widget/loading_widget.dart';
import 'package:tinodeflutter/global/DioClient.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/tinode/tinode.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/utils.dart';

import '../../components/MyAssetPicker.dart';


class SettingBlockScreen extends StatefulWidget {
  SettingBlockScreen({super.key, required this.tinode });
Tinode tinode;
  @override
  State<SettingBlockScreen> createState() => _SettingBlockScreen();
}

class _SettingBlockScreen extends State<SettingBlockScreen> {
  late Tinode tinode;

  late List<UserModel> users;
  late Future userFuture;
  int userPage = 0;
  bool hasUserNextPage = false;
  bool isLoading = false;
  ScrollController userScrollController = ScrollController();

  Future<List<UserModel>> initUsers() async{
    var response = await DioClient.getBlockUsers(20, 0);
    List<UserModel> userResults = response.data["result"] == null ? [] : response
        .data["result"].map((json) => UserModel.fromJson(json["user"])).toList().cast<
        UserModel>();
    userPage = 1;
    hasUserNextPage = false;
    users = userResults;

    return users;
  }

  Future<void> getUserNextPage() async {
    if (!isLoading && userScrollController.position.extentAfter < 200 && hasUserNextPage) {
      var response = await DioClient.getBlockUsers(20, userPage);
      List<UserModel> userResults = response.data["result"] == null ? [] : response
          .data["result"].map((json) => UserModel.fromJson(json)).toList().cast<
          UserModel>();
      userPage += 1;
      hasUserNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
      setState(() {
        users.addAll(userResults);
      });
      isLoading = true;
    }
  }

  @override
  void initState() {
    tinode = widget.tinode;
    userFuture = initUsers();
    super.initState();
    userScrollController.addListener(getUserNextPage);
  }

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
                        text: "block_manage".tr(),
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
              padding: EdgeInsets.only(left: 20,right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15,),

                    AppText(
                      text: "setting_blocked_user_title".tr(),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: 5,),

                    AppText(
                      text: "setting_blocked_user_desc".tr(),
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

                    SizedBox(height: 15,),
                  ],
                ),
            ),

            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      FutureBuilder(
                        future: userFuture,
                        builder: (context, snapshot){
                          if(snapshot.hasData){
                            if(users.isEmpty){
                              return Expanded(
                                  child: Center(
                                    child: AppText(
                                      text: "empty_block_user".tr(),
                                      fontSize: 13,
                                      color: ColorConstants.halfWhite,
                                    ),
                                  )
                              );
                            }

                            return Expanded(
                                child: MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  removeLeft: true,
                                  removeRight: true,
                                  removeBottom: true,
                                  child: ListView.builder(
                                      controller: userScrollController,
                                      itemCount: hasUserNextPage ? users.length+1 : users.length,
                                      shrinkWrap: true,
                                      padding: EdgeInsets.only(top: 15,left: 10, right: 10),
                                      itemBuilder: (context,index){
                                        if(hasUserNextPage && users.length == index){
                                          return Padding(
                                            padding: EdgeInsets.only(top: 30, bottom: 50),
                                            child: LoadingWidget(),
                                          );
                                        }
                                        Key key = Key(users[index].id.toString());
                                        return BlockUserListItemWidget(key: key, tinode: tinode, user: users[index], deleteUser: (){
                                          setState(() {
                                            users.removeAt(index);
                                          });
                                        },);
                                      }),
                                )
                            );
                          }
                          return Expanded(
                            child: Center(
                              child: LoadingWidget(),
                            ),
                          );
                        },
                      ),
                    ]
                ),
            )
          ],
        )
    );

  }
}