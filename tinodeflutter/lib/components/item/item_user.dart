
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tinodeflutter/Constants/ImageUtils.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/model/userModel.dart';

import '../../../Constants/ImageConstants.dart';
import '../../Constants/ColorConstants.dart';

class ItemUser extends StatelessWidget {
  UserModel user;
  bool selected;
  bool isDisabled;
  final onClick;

  ItemUser({Key? key, required this.user, required this.selected, this.onClick, this.isDisabled=false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        if(!isDisabled){
          onClick();
        }
      },
      child: Container(
          padding: const EdgeInsets.only(bottom: 5),
          decoration: 
            BoxDecoration(
                        border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300, // 선의 색상
                          width: 0.5, // 선의 두께
                        ),
                      ),
                    ),
        child: Column(
        children: [
           const SizedBox(height: 5),
          Row(
            children: [
              const SizedBox(width: 10),
              ClipOval(
                  child: Opacity(
                    opacity: isDisabled ? 0.3 : 1,
                    child: ImageUtils.ProfileImage(user.picture ?? "", 45, 45)
                  )
              ),
              
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                  opacity: isDisabled ? 0.3 : 1,
                    child: AppText(
                    text: user.name ?? '',
                    overflow: TextOverflow.ellipsis,
                    fontSize: 13,
                    maxLine: 1,
                    color: Colors.black, //selected ? ColorConstants.colorMain : Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                  ),
                  // SizedBox(height: 3,),
                  // Opacity(
                  //   opacity: isDisabled ? 0.3 : 1,
                  //   child: AppText(
                  //   text: user.id ?? '',
                  //   overflow: TextOverflow.ellipsis,
                  //   fontSize: 12,
                  //   maxLine: 1,
                  //   color: ColorConstants.halfBlack,
                  // ),
                  // ),
                ],
              )),
              const SizedBox(width: 6),
              Opacity(
                opacity: isDisabled ? 0.3 : 1,
                child: 
                 isDisabled ? Image.asset(ImageConstants.chatRadioOnDisabled, height: 24, width: 24, color: Colors.grey,) :
                 selected? Image.asset(ImageConstants.chatRadioOn,  height: 24, width: 24, color: ColorConstants.colorMain) : 
                  Image.asset(ImageConstants.chatRadioOff,  height: 24, width: 24, color: Colors.grey),
              ),
              const SizedBox(width: 10),
            ],
          ),
         // const SizedBox(height: 10),
        ],
      ),
    ));
  }
}
