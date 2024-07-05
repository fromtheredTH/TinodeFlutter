
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:tinodeflutter/Screen/ProfileScreen.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/global/DioClient.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/tinode/tinode.dart';

import '../../Constants/ColorConstants.dart';
import '../../Constants/FontConstants.dart';
import '../../Constants/ImageConstants.dart';
import '../../Constants/ImageUtils.dart';
import '../../Constants/utils.dart';

import 'loading_widget.dart';

class BlockUserListItemWidget extends StatefulWidget {
  BlockUserListItemWidget({Key? key,required this.tinode, required this.user, required this.deleteUser}) : super(key: key);
  User user;
  Tinode tinode;
  Function() deleteUser;

  @override
  State<BlockUserListItemWidget> createState() => _BlockUserListItemWidget();
}

class _BlockUserListItemWidget extends State<BlockUserListItemWidget> {
  late User user;
  late Tinode tinode;

  late List<User> users;
  late Future userFuture;
  int userPage = 0;
  bool hasUserNextPage = false;
  bool isLoading = false;
  ScrollController userScrollController = ScrollController();

  Future<List<User>> initUsers() async{
    var response = await DioClient.getBlockUsers(20, 0);
    List<User> userResults = response.data["result"] == null ? [] : response
        .data["result"].map((json) => User.fromJson(json)).toList().cast<
        User>();
    userPage = 1;
    hasUserNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
    users = userResults;

    return users;
  }

  Future<void> getUserNextPage() async {
    if (!isLoading && userScrollController.position.extentAfter < 200 && hasUserNextPage) {
      var response = await DioClient.getBlockUsers(20, userPage);
      List<User> userResults = response.data["result"] == null ? [] : response
          .data["result"].map((json) => User.fromJson(json)).toList().cast<
          User>();
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
    user = widget.user;
    tinode = widget.tinode;
    userFuture = initUsers();
    super.initState();
    userScrollController.addListener(getUserNextPage);
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: Get.width*0.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: (){
                      if(user.id != "") {
                        Get.to(ProfileScreen(user: user, tinode: tinode,));
                      }
                    },
                    child: ClipOval(
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle
                        ),
                        child: ImageUtils.ProfileImage(
                            user.picture,
                            45,
                            45
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: Get.width*0.03),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(text: user.id != "" ? user.id : "deleted_account".tr(),
                          fontSize: 13,
                          color: ColorConstants.white,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w700
                      ),

                      SizedBox(height: 5,),

                      AppText(text: user.name,
                          fontSize: 13,
                          color: ColorConstants.halfWhite,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w400
                      )
                    ],
                  )
                ],
              ),
            ),

            GestureDetector(
              onTap: () async{
                //await DioClient.userUnBlock(user.id);
                widget.deleteUser();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: ColorConstants.red,
                        width: 1
                    )
                ),
                child: AppText(
                  text: "block_cancel".tr(),
                  color: ColorConstants.red,
                  fontSize: 14,
                ),
              ),
            )
          ]
        ),

        SizedBox(height: 15,)
      ],
    );
  }
}
