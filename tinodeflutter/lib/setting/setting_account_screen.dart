import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:tinodeflutter/Constants/Constants.dart';
import 'package:tinodeflutter/Constants/ImageUtils.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/global/DioClient.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/page/base/page_layout.dart';
import 'package:tinodeflutter/setting/setting_remove_account.dart';
import 'package:tinodeflutter/tinode/tinode.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/utils.dart';

import '../../components/MyAssetPicker.dart';

class SettingAccountScreen extends StatefulWidget {
  SettingAccountScreen(
      {super.key, required this.tinode, required this.onChangedUser});
  Function(UserModel) onChangedUser;
  Tinode tinode;

  @override
  State<SettingAccountScreen> createState() => _SettingAccountScreen();
}

class _SettingAccountScreen extends State<SettingAccountScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController idController = TextEditingController();

  RxBool isTapIdOkBtn = false.obs;
  RxBool isNicknameEmpty = false.obs;
  RxBool isIdCorrect = true.obs;
  RxBool isNicknameNotDuplicate = true.obs;

  RxBool isTapNameOkBtn = false.obs;
  RxBool isNameEmpty = false.obs;
  RxBool isNameCorrect = true.obs;

  late Tinode tinode;

  @override
  void initState() {
    super.initState();
    tinode = widget.tinode;
    emailController.text = Constants.user.email ?? "";
    nameController.text = Constants.user.name;
    idController.text = Constants.user.id;
  }

  Future<void> onClickSaveButton() async {
    isTapIdOkBtn.value = true;
    isTapNameOkBtn.value = true;

    if (idController.text.isEmpty ||
        !isIdCorrect.value ||
        nameController.text.isEmpty ||
        !isNameCorrect.value) {
      return;
    }

    if (idController.text != Constants.user.id) {
      var idResponse =
          await DioClient.checkNickname(idController.text);
      if (idResponse.data["result"]["success"]) {
        isNicknameNotDuplicate.value = false;
        return;
      }
    }

    //var response = await DioClient.updateAccount(nameController.text, idController.text);
    //Constants.user = User.fromJson(response.data["result"]["user"]);
    Utils.showToast("edit_account_complete".tr());
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
        child: Scaffold(
            backgroundColor: Colors.grey[800],
            resizeToAvoidBottomInset: false,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(height: Get.height * 0.03),
                    Padding(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: Icon(Icons.arrow_back_ios,
                                      color: Colors.white)),
                              AppText(
                                text: "account".tr(),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              )
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.to(SettingRemoveAccountScreen());
                            },
                            child: AppText(
                              text: "remove_account".tr(),
                              fontSize: 14,
                              color: ColorConstants.halfWhite,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: "email".tr(),
                              fontWeight: FontWeight.w700,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 13,
                                fontFamily: FontConstants.AppFont,
                                fontWeight: FontWeight.w400,
                              ),
                              readOnly: true,
                              controller: emailController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(
                                        color:
                                            Color(0xFFFFFFFF).withOpacity(0.5)),
                                  ),
                                  hintText: "",
                                  hintStyle: TextStyle(
                                    color: Color(0xFFFFFFFF).withOpacity(0.5),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: FontConstants.AppFont,
                                    fontSize: 13,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10)),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              children: [
                                AppText(
                                  text: "id",
                                  fontWeight: FontWeight.w700,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Utils.showToast("nickname_guide".tr());
                                  },
                                  child: ImageUtils.setImage(
                                      ImageConstants.accountEditQuestion,
                                      16,
                                      16),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 13,
                                fontFamily: FontConstants.AppFont,
                                fontWeight: FontWeight.w400,
                              ),
                              onChanged: (value) {
                                isTapIdOkBtn.value = false;
                                isNicknameEmpty.value = value.isEmpty;
                                isNicknameNotDuplicate.value = true;
                                if (value.isNotEmpty &&
                                    value.length < 4 &&
                                    !GetUtils.isUsername(value)) {
                                  isIdCorrect.value = false;
                                } else {
                                  isIdCorrect.value = true;
                                }
                              },
                              controller: idController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(
                                        color:
                                            Color(0xFFFFFFFF).withOpacity(0.5)),
                                  ),
                                  hintText: "",
                                  hintStyle: TextStyle(
                                    color: Color(0xFFFFFFFF).withOpacity(0.5),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: FontConstants.AppFont,
                                    fontSize: 13,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10)),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Obx(() => AppText(
                                  text: isIdCorrect.value &&
                                          isNicknameNotDuplicate.value &&
                                          isNicknameEmpty.value
                                      ? "nickname_incorrect".tr()
                                      : isIdCorrect.value &&
                                              isNicknameNotDuplicate.value
                                          ? "nickname_enable".tr()
                                          : !isIdCorrect.value
                                              ? "nickname_length".tr()
                                              : "nickname_disable".tr(),
                                  color: isIdCorrect.value &&
                                          isNicknameNotDuplicate.value &&
                                          isNicknameEmpty.value
                                      ? isTapIdOkBtn.value
                                          ? ColorConstants.red
                                          : ColorConstants.halfWhite
                                      : isIdCorrect.value &&
                                              isNicknameNotDuplicate.value
                                          ? ColorConstants.halfWhite
                                          : !isIdCorrect.value
                                              ? ColorConstants.red
                                              : ColorConstants.red,
                                  fontSize: 11,
                                  maxLine: 2,
                                )),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              children: [
                                AppText(
                                  text: "name".tr(),
                                  fontWeight: FontWeight.w700,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Utils.showToast("name_guide".tr());
                                  },
                                  child: ImageUtils.setImage(
                                      ImageConstants.accountEditQuestion,
                                      16,
                                      16),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 13,
                                fontFamily: FontConstants.AppFont,
                                fontWeight: FontWeight.w400,
                              ),
                              onChanged: (value) {
                                isTapNameOkBtn.value = false;
                                isNameEmpty.value = value.isEmpty;
                                if (value.isNotEmpty && value.length < 2) {
                                  isNameCorrect.value = false;
                                } else {
                                  isNameCorrect.value = true;
                                }
                              },
                              controller: nameController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(
                                        color:
                                            Color(0xFFFFFFFF).withOpacity(0.5)),
                                  ),
                                  hintText: "",
                                  hintStyle: TextStyle(
                                    color: Color(0xFFFFFFFF).withOpacity(0.5),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: FontConstants.AppFont,
                                    fontSize: 13,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10)),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Obx(() => AppText(
                                  text:
                                      !isNameCorrect.value || isNameEmpty.value
                                          ? "name_incorrect".tr()
                                          : "name_enable".tr(),
                                  color:
                                      isNameEmpty.value && isTapNameOkBtn.value
                                          ? ColorConstants.red
                                          : !isNameCorrect.value
                                              ? ColorConstants.red
                                              : ColorConstants.halfWhite,
                                  fontSize: 11,
                                  maxLine: 2,
                                )),
                            SizedBox(
                              height: 25,
                            ),
                          ]),
                    )
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    onClickSaveButton();
                  },
                  child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: ColorConstants.colorMain,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          "save".tr(),
                          style: TextStyle(
                              color: Color(0xFFFFFFFFF),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              fontFamily: FontConstants.AppFont),
                        ),
                      )),
                )
              ],
            )));
  }
}
