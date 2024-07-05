

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/tinode/src/models/topic-subscription.dart';

import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/ImageUtils.dart';
import '../../../Constants/utils.dart';

class BottomProfileWidget extends StatefulWidget{
  BottomProfileWidget({Key? key, required this.user, required this.setting, required this.logout}) : super(key: key);
  User user;
  Function() setting;
  Function() logout;

  @override
  State<BottomProfileWidget> createState() {
    // TODO: implement createState
    return _BottomProfileWidget();
  }
}

class _BottomProfileWidget extends State<BottomProfileWidget> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: Get.width,
      height: 250,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30),
              topRight: Radius.circular(30)),
        color: ColorConstants.colorBg1
      ),
      child: Column(
        children: [
          SizedBox(height: 15,),
          Container(
            height: 8,
            width: 45,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: ColorConstants.white
            ),
          ),
          SizedBox(height: Get.height * 0.02,),

          Padding(
            padding: EdgeInsets.only(left: 10, right: 10,top: 8,bottom: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ImageUtils.ProfileImage(widget.user.picture??"", 50, 50),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          text: widget.user.id != 0 ? widget.user.name : "deleted_account".tr(),
                          fontSize: 14,
                          maxLine: 1,
                          fontWeight: FontWeight.w700,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppText(text: "@${widget.user.name}",
                                fontSize: 12,
                                color: ColorConstants.halfWhite),

                            SizedBox(width: 5,),

                           //   TagCreatorWidget(positionIndex: widget.user.profile.jobGroup,)
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  color: ColorConstants.halfWhite,
                  height: 0.5,
                  width: double.maxFinite,
                ),

                GestureDetector(
                  onTap: (){
                    Get.back();
                    widget.setting();
                  },
                  child: Row(
                    children: [
                      ImageUtils.setImage(ImageConstants.profileSetting, 24, 24),
                      SizedBox(width: 10,),
                      AppText(
                        text: "setting".tr(),
                        fontSize: 14,
                      )
                    ],
                  ),
                ),

                SizedBox(height: 15,),

                GestureDetector(
                  onTap: (){
                    Get.back();
                    widget.logout();
                  },
                  child: Row(
                    children: [
                      ImageUtils.setImage(ImageConstants.logout, 24, 24),
                      SizedBox(width: 10,),
                      AppText(
                        text: "logout".tr(),
                        fontSize: 14,
                      )
                    ],
                  ),
                ),

                // Container(
                //   margin: EdgeInsets.symmetric(vertical: 20),
                //   color: ColorConstants.halfWhite,
                //   height: 0.5,
                //   width: double.maxFinite,
                // ),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     AppText(
                //       text: "current_get".tr(),
                //       fontSize: 14,
                //     ),

                //     Row(
                //       children: [
                //         ImageUtils.setImage(ImageConstants.zem, 24, 24),
                //         SizedBox(width: 10,),
                //         AppText(
                //           text: "${widget.user.coin.zem}",
                //           fontSize: 16,
                //           color: ColorConstants.colorMain,
                //           fontWeight: FontWeight.w700,
                //         ),
                //         AppText(
                //           text: " ZEM",
                //           fontSize: 16,
                //           color: ColorConstants.textGry,
                //           fontWeight: FontWeight.w700,
                //         )
                //       ],
                //     )
                //   ],
                // ),

                // SizedBox(height: 15,),

                // AppButton(
                //     text: "zem_charge".tr(),
                //     margin: 0,
                //     onTap: (){
                //       Utils.showToast("taost_function_not_enable".tr());
                //     }
                // )
              ],
            ),
          ),


          SizedBox(height: 20,)
        ],
      ),
    );
  }
}
