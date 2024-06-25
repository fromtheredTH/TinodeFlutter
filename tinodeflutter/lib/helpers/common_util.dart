import 'dart:io';


import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sprintf/sprintf.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

String getLang(int uid) {
  String lang = uid == 1
      ? 'id'
      : uid == 3
          ? 'ko'
          : uid == 4
              ? 'ja'
              : 'en';
  return lang;
}

String sizeStr(int size, int totalSize) {
  if (totalSize < 1024) {
    return '${size}';
  } else if (totalSize < 1024 * 1024) {
    return '${(size / 1024).toStringAsFixed(1)}';
  } else if (totalSize < 1024 * 1024 * 1024) {
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}';
  }
  return '';
}

String totalSizeStr(int size) {
  if (size < 1024) {
    return '${size}byte';
  } else if (size < 1024 * 1024) {
    return '${(size / 1024).toStringAsFixed(1)}KB';
  } else if (size < 1024 * 1024 * 1024) {
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
  return '';
}

void showToast(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 14.0);
}

String enumToString(value) {
  return value.toString().split('.').last;
}

String formatAmount(int num) {
  NumberFormat format = new NumberFormat("#,###");
  return format.format(num);
}

Future<String> getVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

bool keyboardIsVisible(BuildContext context) {
  return !(MediaQuery.of(context).viewInsets.bottom == 0.0);
}

String getDevType() {
  String target = "";
  if (Platform.isAndroid) {
    target = "android";
  } else {
    target = "ios";
  }
  return target;
}

String chatTime(String chatAt) {
  String result = "";
  if (chatAt.isNotEmpty) {
    DateFormat format1 = DateFormat('yyyy-MM-ddThh:mm:ss.sssZ');
    DateFormat diferYearFormat = DateFormat('yyyy');
    DateFormat format2 = DateFormat('aa hh:mm');
    DateFormat format3 = DateFormat('date_format_mm_dd'.tr());
    DateFormat format4 = DateFormat('yyyy-MM-dd');
    DateTime date = format1.parse(chatAt);
    date = date.add(const Duration(hours: 9));
    final date2 = DateTime.now();
    final difference = date2.difference(date).inDays;
    if (difference < 1) {
      result = format2.format(date);
    } else if(diferYearFormat.format(date) == diferYearFormat.format(date2)){
      result = format3.format(date);
    } else {
      result = format4.format(date);
    }
  }
  return result;
}

String chatTime2(String chatAt, ) {
  String result = "";
  if (chatAt.isNotEmpty) {
    DateFormat format1 = DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ');
    //DateFormat format2 = DateFormat('aa hh:mm');
    DateFormat format2 ;
    DateTime date = format1.parse(chatAt);
    date = date.add(const Duration(hours: 9));
    //result = format2.format(date);
    DateTime now = DateTime.now();
    if(date.year != now.year){
      format2 = DateFormat('dm_time_format2'.tr());
    }else if(date.month != now.month || date.day != now.day){
      DateTime yesterDay = now.subtract(Duration(days: 1));
      if(date.month == yesterDay.month && date.day == yesterDay.day  ){
        return "yesterday".tr();
      }
      else {
      format2 = DateFormat('dm_time_format3'.tr());
      }
    }else {
      format2 = DateFormat('hh:mm aa');
    }
    result = format2.format(date);
  }
  return result;
}

String chatTime3(String chatAt) {
  String result = "";
  if (chatAt.isNotEmpty) {
    DateFormat format1 = DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ');
    DateFormat? format2;
    DateTime date = format1.parse(chatAt);
    date = date.add(const Duration(hours: 9));

    DateTime now = DateTime.now();
    format2 = DateFormat('hh:mm aa');
    result = format2!.format(date);
  }
  return result;
}

// String chatContent(String contents, int type) {
//   if (type == eChatType.TEXT.index) {
//     return contents;
//   } else if (type == eChatType.IMAGE.index) {
//     return "image".tr();
//   } else if (type == eChatType.VIDEO.index) {
//     return "video".tr();
//   } else if (type == eChatType.AUDIO.index) {
//     return "audio".tr();
//   }
//   return '';
// }

String pad2(int i) {
  return i.toString().padLeft(2, '0');
}

// String parentChatNick(List<UserDto> users, UserDto? me, List<ChatMsgDto> list, int chat_id) {
//   List<UserDto> usersAll = [];
//   usersAll.addAll(users);
//   if (me != null) {
//     usersAll.add(me);
//   }
//   if (chat_id == 0) return 'unknown'.tr();
//   List<ChatMsgDto> dto = list.where((element) => element.id == chat_id).toList();
//   if (dto.isNotEmpty) {
//     List<UserDto> list = usersAll.where((element) => element.id == dto[0].sender_id).toList();
//     if (list.isEmpty) {
//       return 'unknown'.tr();
//     }
//     return dto[0].sender?.nickname ?? '';
//   }
//   return '';
// }
