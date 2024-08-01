
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:tinodeflutter/Constants/Constants.dart';
import 'package:tinodeflutter/Screen/ProfileScreen.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/components/widget/BtnBottomSheetWidget.dart';
import 'package:tinodeflutter/model/btn_bottom_sheet_model.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/tinode/tinode.dart';

import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/ImageUtils.dart';
import '../../../Constants/utils.dart';



class UserListItemWidget extends StatefulWidget {
  UserListItemWidget({Key? key, required this.user, this.isGoProfile = true, this.isShowAction = true, this.isMini=false, required this.deleteUser, this.followUser, this.unFollowUser}) : super(key: key);
  UserModel user;
  bool isShowAction;
  bool isMini;
  bool isGoProfile;
  Function() deleteUser;
  Function()? followUser;
  Function()? unFollowUser;


  @override
  State<UserListItemWidget> createState() => _UserListItemWidget();
}

class _UserListItemWidget extends State<UserListItemWidget> {
  // late TopicSubscription userTopicSub;
  late UserModel user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }




  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return 
    // Column(
    //   children: [
        Container(
          padding: const EdgeInsets.only(bottom: 5),
          decoration: 
            BoxDecoration(
                        border: Border(
                        bottom: BorderSide(
                          color: Colors.grey, // 선의 색상
                          width: 0.5, // 선의 두께
                        ),
                      ),
                    ),
        child:
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: (){
                  if(widget.isGoProfile){
                    if(user.id != "") {
                      Get.to(ProfileScreen(user: user, ));
                    }
                  }
                },
                child: Container(
                  width: Get.width*0.8,
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: (){
                          if(widget.isGoProfile){
                            if(user.id != "") {
                              Get.to(ProfileScreen(user: user, ));
                            }
                          }
                        },
                        child: ClipOval(
                          child: Container(
                            width: widget.isMini ? 24 : 45,
                            height: widget.isMini ? 24 : 45,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                            ),
                            child: ImageUtils.ProfileImage(
                                user.picture,
                                widget.isMini ? 24 : 45,
                                widget.isMini ? 24 : 45
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: Get.width*0.03),
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [

                                  Flexible(
                                    child: GestureDetector(
                                      onTap: (){
                                        if(widget.isGoProfile){
                                          if(user.id!="") {
                                            Get.to(ProfileScreen(user: user, ));
                                          }
                                        }
                                      },
                                      child: AppText(text: user.id!="" ? user.name : "deleted_account".tr(),
                                          fontSize: widget.isMini ? 14 : 15,
                                          color: ColorConstants.black,
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          fontFamily: FontConstants.AppFont,
                                          fontWeight: FontWeight.w600
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: widget.isMini ? 5 : 10),

                                 // TagCreatorWidget(positionIndex: user.profile.jobGroup,),
                                  SizedBox(width: widget.isMini ? 4 : 8),

                                  //TagDevWidget(positionIndex: user.profile.jobPosition,)

                                ],
                              ),

                              SizedBox(height: widget.isMini ?  2: 5,),

                              // Row(
                              //   crossAxisAlignment: CrossAxisAlignment.center,
                              //   mainAxisAlignment: MainAxisAlignment.start,
                              //   children: [

                              //     Expanded(
                              //         child: GestureDetector(
                              //             onTap: (){
                              //               if(widget.isGoProfile){
                              //                 if(user.id!="") {
                              //                   Get.to(ProfileScreen(user: user, ));
                              //                 }
                              //               }
                              //             },
                              //             child: AppText(text: user.name ?? "",
                              //                 fontSize: widget.isMini ? 12 : 13,
                              //                 color: ColorConstants.black,
                              //                 textAlign: TextAlign.start,
                              //                 overflow: TextOverflow.ellipsis,
                              //                 fontFamily: FontConstants.AppFont,
                              //                 fontWeight: FontWeight.w400
                              //             )
                              //         )
                              //     )
                              //   ],
                              // ),
                            ],
                          )
                      )
                    ],
                  ),
                ),
              ),
            ),

            if(widget.isShowAction && user.id != Constants.user.id)
              !user.isFreind ?
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        user.isFreind = true;
                      });
                    //  var response = await DioClient.postUserFollow(user.id);
                      setState(() {
                        if(widget.followUser != null){
                          widget.followUser!();
                        }
                      });
                    },
                    child: ImageUtils.setImage(ImageConstants.followUser, 30, 30),
                  )
                  :
              GestureDetector(
                onTap: (){
                  List<BtnBottomSheetModel> items = [];
                  items.add(BtnBottomSheetModel(ImageConstants.reportUserIcon, "user_report".tr(), 0));
                  items.add(BtnBottomSheetModel(ImageConstants.block, "user_block".tr(), 1));
                  items.add(BtnBottomSheetModel(ImageConstants.unSubscribe, "follow_cancel".tr(), 2));


                  Get.bottomSheet(enterBottomSheetDuration: Duration(milliseconds: 100), exitBottomSheetDuration: Duration(milliseconds: 100),BtnBottomSheetWidget(btnItems: items, onTapItem: (menuIndex) async {
                    if(menuIndex == 0){
                      // showModalBottomSheet<dynamic>(
                          // isScrollControlled: true,
                          // context: context,
                          // useRootNavigator: true,
                          // backgroundColor: Colors.transparent,
                          // builder: (BuildContext bc) {
                          //   return ReportUserDialog(onConfirm: (reportList, reason) async {
                          //     var response = await DioClient.reportUser(user.id, reportList, reason);
                          //     widget.deleteUser();
                          //     Utils.showToast("report_complete".tr());
                          //   },);
                          // }
                      // );
                    }else if(menuIndex == 1){
                  //    var response = await DioClient.postUserBlock(user.id);
                      widget.deleteUser();
                      Utils.showToast("ban_complete".tr());
                    }else {
                      setState(() {
                       // user.isFollowing = false;
                      });
                   //   var response = await DioClient.postUserUnFollow(user.id);
                      setState(() {
                        if(widget.unFollowUser != null){
                          widget.unFollowUser!();
                        }
                      });
                    }
                  }));
                },
                child: Icon(
                      Icons.more_horiz,
                      size: 30,
                      color: Colors.black,
                    ),
                // child: SvgPicture.asset(ImageConstants.moreIcon, width: 30,)
              ),
          ],
        ),
        );
        // SizedBox(height: widget.isMini ? 10 : 25,)
    //   ],
    // );
  }
}
