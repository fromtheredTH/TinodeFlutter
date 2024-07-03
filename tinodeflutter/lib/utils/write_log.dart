import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer';

class WriteLog {
  
  static DateTime sendApiTime = DateTime.now();
  static  DateTime apiComeTIme = DateTime.now();
  static  DateTime start_dt2 = DateTime.now();
  static  DateTime renderingEndTime = DateTime.now();

  static TimeDifferenceApi()
  {
    return apiComeTIme.difference(sendApiTime);
  }
  
  static TimeDifferenceClientRendering()
  {
    return renderingEndTime.difference(apiComeTIme);
  }
  
  static TimeDifferenceOverall()
  {
    return renderingEndTime.difference(sendApiTime);
  }

  
  static Future write(String string, {String fileName = "log.txt"}) async {

  
    Logger().log(Level.debug, "$fileName\n$string");
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        {
          final dir = await getExternalStorageDirectory();

          return File('${dir!.path}/$fileName').writeAsString(string,mode:FileMode.append);
        }
      case TargetPlatform.fuchsia:
        // TODO: Handle this case.
        break;
      case TargetPlatform.iOS:
        Logger().log(Level.debug, "$fileName\n$string");
        // TODO: Handle this case.
        break;
      case TargetPlatform.linux:
        // TODO: Handle this case.
        break;
      case TargetPlatform.macOS:
        // TODO: Handle this case.
        break;
      case TargetPlatform.windows:
        // TODO: Handle this case.
        break;
    }
  }
}
