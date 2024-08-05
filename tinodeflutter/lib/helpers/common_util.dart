import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sprintf/sprintf.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:tinodeflutter/model/MessageModel.dart';
import 'package:tinodeflutter/model/userModel.dart';

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

String chatTime2(String chatAt) {
  String result = "";
  if (chatAt.isNotEmpty) {
    try {
      // ISO 8601 형식으로 파싱
      DateTime date = DateTime.parse(chatAt);
      // 한국 시간대로 변환 (UTC +9)
      date = date.add(const Duration(hours: 9));

      DateTime now = DateTime.now();
      DateFormat format2;

      if (date.year != now.year) {
        format2 = DateFormat('yyyy-MM-dd');
      } else if (date.month != now.month || date.day != now.day) {
        DateTime yesterDay = now.subtract(Duration(days: 1));
        if (date.month == yesterDay.month && date.day == yesterDay.day) {
          return "어제";
        } else {
          format2 = DateFormat('MM-dd');
        }
      } else {
        format2 = DateFormat('HH:mm');
      }

      result = format2.format(date);
    } catch (e) {
      print("Error parsing date: $e");
      result = "Invalid date";
    }
  }
  return result;
}
// String chatTime2(String chatAt) {
//   String result = "";
//   if (chatAt.isNotEmpty) {
//     try {
//       // ISO 8601 형식으로 파싱
//       DateTime date = DateTime.parse(chatAt).toLocal();

//       DateTime now = DateTime.now();
//       DateFormat format2;

//       if (date.year != now.year) {
//         format2 = DateFormat('yyyy-MM-dd');
//       } else if (date.month != now.month || date.day != now.day) {
//         DateTime yesterDay = now.subtract(Duration(days: 1));
//         if (date.month == yesterDay.month && date.day == yesterDay.day) {
//           return "어제";
//         } else {
//           format2 = DateFormat('MM-dd');
//         }
//       } else {
//         format2 = DateFormat('HH:mm');
//       }

//       result = format2.format(date);
//     } catch (e) {
//       print("Error parsing date: $e");
//       result = "Invalid date";
//     }
//   }
//   return result;
// }

// String chatTime2(String chatAt, ) {
//   String result = "";
//   if (chatAt.isNotEmpty) {
//     DateFormat format1 = DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ');
//     //DateFormat format2 = DateFormat('aa hh:mm');
//     DateFormat format2 ;
//     DateTime date = format1.parse(chatAt);
//     date = date.add(const Duration(hours: 9));
//     //result = format2.format(date);
//     DateTime now = DateTime.now();
//     if(date.year != now.year){
//       format2 = DateFormat('dm_time_format2'.tr());
//     }else if(date.month != now.month || date.day != now.day){
//       DateTime yesterDay = now.subtract(Duration(days: 1));
//       if(date.month == yesterDay.month && date.day == yesterDay.day  ){
//         return "yesterday".tr();
//       }
//       else {
//       format2 = DateFormat('dm_time_format3'.tr());
//       }
//     }else {
//       format2 = DateFormat('hh:mm aa');
//     }
//     result = format2.format(date);
//   }
//   return result;
// }

String chatTime3(String chatAt) {
  String result = "";
  if (chatAt.isNotEmpty) {
    // DateFormat format1 = DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ');
    DateFormat? format2;
    DateTime date = DateTime.parse(chatAt);

   // DateTime date = format1.parse(chatAt);
    date = date.add(const Duration(hours: 9));

    DateTime now = DateTime.now();
    format2 = DateFormat('hh:mm aa');
    result = format2!.format(date);
  }
  return result;
}

String chatContent(String contents, eChatType type) {
  if (type == eChatType.TEXT) {
    return contents;
  } else if (type == eChatType.IMAGE) {
    return "image".tr();
  } else if (type == eChatType.VIDEO) {
    return "video".tr();
  } else if (type == eChatType.AUDIO) {
    return "audio".tr();
  }
  return '';
}

String pad2(int i) {
  return i.toString().padLeft(2, '0');
}

String parentChatNick(List<UserModel> users, UserModel? me, List<MessageModel> list, int chat_id) {
  List<UserModel> usersAll = [];
  usersAll.addAll(users);
  if (me != null) {
    usersAll.add(me);
  }
  if (chat_id == 0) return 'unknown'.tr();
  List<MessageModel> messageDatas = list.where((element) => element.id == chat_id).toList();
  if (messageDatas.isNotEmpty) {
    List<UserModel> list = usersAll.where((element) => element.id == messageDatas[0].sender_id).toList();
    if (list.isEmpty) {
      return 'unknown'.tr();
    }
    return messageDatas[0].sender_id ?? '';
  }
  return '';
}


  String formatMilliseconds(int milliseconds) {
    // 밀리초를 초로 변환
    int totalSeconds = (milliseconds / 1000).floor();

    // 분과 초를 계산
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;

    // 초가 한 자리 수일 경우 앞에 0을 추가
    String formattedSeconds = seconds < 10 ? '0$seconds' : '$seconds';

    return '$minutes:$formattedSeconds';
  }

  String changePathToLink(String path)
  {
    String link = "https://$hostAddres/$path?apikey=$apiKey&auth=token&secret=$url_encoded_token";
    return link;
  }



  void startTimer() {
    late Timer _timer;
    int _seconds = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _seconds++;
      print(_formatTime(_seconds));
    });
  }

  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  String sortAndCombineStrings(String a, String b) {
  // 두 문자열을 소문자로 변환하여 비교
  if (a.compareTo(b) <= 0) {
    return a + b;
  } else {
    return b + a;
  }
}

int stringToAsciiSum(String input) {
  int asciiSum = 0;
  
  for (int i = 0; i < input.length; i++) {
    asciiSum += input.codeUnitAt(i);
  }
  
  return asciiSum;
}

bool stringToBool(String value) {
  return value.toLowerCase() == 'true';
}

Future<void> saveData(String key, Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(data));
}
  
Future<String> encodeStringToBase64(String originStr) async {
  String base64String = base64.encode(utf8.encode(originStr));
  return base64String;
}