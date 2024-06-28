import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ColorConstants.dart';


class Utils {
  static AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );
  static final _storage = new FlutterSecureStorage(aOptions: _getAndroidOptions());

  static int _getExtendedVersionNumber(String version) {
    List versionCells = version.split('.');
    versionCells = versionCells.map((i) => int.parse(i)).toList();
    return versionCells[0] * 100000 + versionCells[1] * 1000 + versionCells[2];
  }

  static int versionCompare(String left, String right) {
    int leftNumber = _getExtendedVersionNumber(left); // return 10020003
    int rightNumber = _getExtendedVersionNumber(right); // return 10020011
    if (leftNumber > rightNumber) return 1;
    if (leftNumber < rightNumber) return -1;
    return 0;
  }

  static Future<bool> isAutoLogin() async {
    String? isAutoLogin = await _storage.read(key: "isAutoLogin");
    if(isAutoLogin == null || isAutoLogin! == "false") {
      return false;
    }else{
      return true;
    }
  }

  static void showDialogWidget(BuildContext context){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: ColorConstants.colorMain),
            ),
          );
        }
    );
  }

  static Future<bool> isSetAlram() async {
    String? alramValue = await _storage.read(key: "alramValue");

    if(alramValue == null || alramValue! == "false"){
      return false;
    }else{
      return true;
    }
  }

  static Future<void> setAlram(bool isAlramValue) async {
    await _storage.write(key: "alramValue", value: isAlramValue.toString());
  }

  static Future<bool> isFirstLoading() async {
    String? isFirstLoading = await _storage.read(key: "isFirstLoading");
    if(isFirstLoading == null || isFirstLoading! == "true") {
      await _storage.write(key: "isFirstLoading", value: "false");
      return true;
    }else{
      return false;
    }
  }

  static Future<String> getAutoEmail() async {
    String? autoEmail = await _storage.read(key: "autoEmail");
    return autoEmail ?? "";
  }

  static Future<String> getAutoSNSType() async {
    String? autoSnsType = await _storage.read(key: "autoSnsType");
    return autoSnsType ?? "";
  }

  static Future<String> getAutoProvider() async {
    String? autoProvider = await _storage.read(key: "autoProvider");
    return autoProvider ?? "";
  }

  static Future<void> setAutoLogin(String email, String provider, String snsType) async {
    await _storage.write(key: "autoEmail", value: email);
    await _storage.write(key: "autoSnsType", value: snsType);
    await _storage.write(key: "autoProvider", value: provider);
    await _storage.write(key: "isAutoLogin", value: "true");
  }

  static Future<void> releaseAutoLogin() async {
    await _storage.write(key: "alramValue", value: "true");
    await _storage.write(key: "autoEmail", value: "");
    await _storage.write(key: "autoSnsType", value: "");
    await _storage.write(key: "autoProvider", value: "");
    await _storage.write(key: "isAutoLogin", value: "false");
  }

  static String getToday(){
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy.MM.dd');
    String strToday = formatter.format(now);
    return strToday;
  }

  static String toPrice(int price) {
    final formatCurrency = NumberFormat.simpleCurrency(
        locale: "ko_KR", name: "", decimalDigits: 0);

    return formatCurrency.format(price);
  }

  static String parseVersionFromYaml(String yamlVersion) {
    return yamlVersion.split('+')[0];
  }

  static void showToast(String text){
    Fluttertoast.showToast(msg: text,
        gravity: ToastGravity.BOTTOM,
        fontSize: 20,
        toastLength: Toast.LENGTH_SHORT
    );
  }

  static void showCustomToast(context,text) {
    final fToast = FToast();
    fToast.init(context);
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.black,
      ),
      child: Text(text,style: TextStyle(color:Colors.white)),
    );

    fToast.showToast(
        child: toast,
        toastDuration: const Duration(seconds: 1),
        positionedToastBuilder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                child: child,
                bottom: 100,
              ),
            ],
          );
        }
    );
  }

  static Future<void> urlLaunch(String url) async {
    Uri _uri = Uri.parse(url);
    if (!await launchUrl(_uri)) {
      throw Exception('Could not launch $_uri');
    }
  }

  static String getTimePost(String time){
    DateTime dateTime = DateTime.parse(time).toLocal();
    DateFormat dateFormat = DateFormat("yyyy-MM-dd a hh:mm", "ko");
    String currentTime = dateFormat.format(dateTime);
    return currentTime;
  }

  static String getTodayDate(){
    DateTime dateTime = DateTime.now().toLocal();
    DateFormat dateFormat = DateFormat("yyyy.MM.dd");
    String currentTime = dateFormat.format(dateTime);
    return currentTime;
  }

  static String getTodayTime(){
    DateTime dateTime = DateTime.now().toLocal();
    DateFormat dateFormat = DateFormat("a hh:mm", "ko");
    String currentTime = dateFormat.format(dateTime);
    return currentTime;
  }

  static String getTodayAA(){
    DateTime dateTime = DateTime.now().toLocal();
    DateFormat dateFormat = DateFormat("a", "ko");
    String currentTime = dateFormat.format(dateTime);
    return currentTime;
  }

  static String getIntToStringTime(int duration){
    duration = (duration / 1000).toInt();
    if(duration < 3600){
      int min = (duration/60).toInt();
      int sec = duration%60;
      return "${min}:${sec.toString().padLeft(2,"0")}";
    }else {
      int hour = (duration/3600).toInt();
      int min = ((duration%3600)/60).toInt();
      int sec = (duration%3600)%60;
      return "${hour}:${min}:${sec.toString().padLeft(2,"0")}";
    }
  }

  static String getMissionTimeToString(int missionTime){
    var isAm = true;
    var hour = 0;
    var min = 0;

    if(missionTime < 720){
      isAm = true;
    }else{
      isAm = false;
    }

    if(isAm){
      hour = (missionTime/60).toInt();
    }else{
      hour = ((missionTime - 720) / 60).toInt();
      if(hour == 0){
        hour = 12;
      }
    }
    min = missionTime%60;

    return "${isAm ? "AM" : "PM"} ${hour.toString().padLeft(2,"0")}:${min.toString().padLeft(2,"0")}";
  }

  static String setNumberFormat(int number){
    var f = NumberFormat("###,###,###,###");
    return f.format(number);
  }

  static void deleteCacheFile(File file) {
    file.exists().then((exists) {
      if(exists){
        file.delete();
      }
    });
  }

  static void deletedCachedAllFiles() async {
    Directory cacheDir = await getApplicationDocumentsDirectory();
    Directory localDir = Directory(cacheDir.path + "/localCachedFiles");
    Directory networkDir = Directory(cacheDir.path + "/networkCachedFiles");

    if(await localDir.exists()){
      localDir.deleteSync(recursive: true);
      await localDir.create();
    }

    if(await networkDir.exists()){
      networkDir.deleteSync(recursive: true);
    }
  }
}

// ignore: avoid_print
void log(String text) => print("[Moti] $text");

///
///
/// shared_preferences helpers
Future<T?> getData<T>({required String key}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final value = prefs.get(key);

  return (value is T) ? value : null;
}

Future<bool> saveData({
  required String key,
  required Object value,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  if (value is int) {
    return prefs.setInt(key, value);
  } else if (value is double) {
    return prefs.setDouble(key, value);
  } else if (value is String) {
    return prefs.setString(key, value);
  } else if (value is bool) {
    return prefs.setBool(key, value);
  } else {
    return false;
  }
}

/// Remove data with [key].
Future<bool> removeData({required String key}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  return prefs.remove(key);
}
