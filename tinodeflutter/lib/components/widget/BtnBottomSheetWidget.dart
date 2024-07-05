
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

import '../../app_text.dart';
import '../../model/btn_bottom_sheet_model.dart';

class BtnBottomSheetWidget extends StatelessWidget {
  BtnBottomSheetWidget(
      {Key? key, required this.btnItems, required this.onTapItem})
      : super(key: key);
  List<BtnBottomSheetModel> btnItems;
  Function(int) onTapItem;

  @override
  Widget build(BuildContext context) {
   
    return 
    Container(
      height: MediaQuery.of(context).padding.bottom + btnItems.length * 60 + 68,
      decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(24), topLeft: Radius.circular(24))),
      child: SingleChildScrollView (child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 15,
          ),
          Center(
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                  color: Color(0xffd9d9d9),
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
          SizedBox(height: 20),
          Column(
              children: btnItems.map((item) {
            return Container(
              height: 60,
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        onTapItem(item.index);
                      },
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (item.imageString.isNotEmpty)
                              Image.asset(
                                item.imageString,
                                width: 24,
                                height: 24,
                              ),
                            if (item.imageString.isNotEmpty)
                              SizedBox(
                                width: 10,
                              ),
                            AppText(
                              text: item.name,
                              fontSize: 16,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: 0.3,
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
            );
          }).toList()),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 27),
        ],
      ),),
    );
  }
}
