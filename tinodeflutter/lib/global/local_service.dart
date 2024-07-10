import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:tinodeflutter/model/userModel.dart';

import 'global.dart';

class LocalService {
  static String PREF_USER = "PREF_USER";
  static String PREF_FCM_TOKEN = "PREF_FCM_TOKEN";
  static String PREF_AUTO_LOGIN = "PREF_AUTO_LOGIN";
  static String PREF_RECENT_KEYWORD = "PREF_RECENT_KEYWORD";
  static String PREF_LANG = "PREF_LANG";

  static void setUser(UserModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(PREF_USER, json.encode(user.toJson()));
  }

  static void removeUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(PREF_USER);
  }

  static Future<UserModel?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString(PREF_USER);
    if (user == null || user.isEmpty) {
      return null;
    }
    return UserModel.fromJson(json.decode(user));
  }

  static void setToken(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(PREF_FCM_TOKEN, value);
  }

  static Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(PREF_FCM_TOKEN);
    if (token == null || token.isEmpty) {
      return "";
    }
    return token;
  }

  static void setAutoLogin(bool enable) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(PREF_AUTO_LOGIN, enable);
  }

  static Future<bool> isAutoLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PREF_AUTO_LOGIN) ?? true;
  }

  static Future<List<String>> setRecentKeyword(String keyword) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keywordList = prefs.getStringList(PREF_RECENT_KEYWORD) ?? [];
    if (keywordList.contains(keyword)) {
      keywordList.remove(keyword);
    }

    keywordList.insert(0, keyword);

    if (keywordList.length >= 10) {
      keywordList = keywordList.take(10).toList();
    }
    prefs.setStringList(PREF_RECENT_KEYWORD, keywordList);

    return keywordList;
  }

  static Future<List<String>> getRecentKeyword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keywordList = prefs.getStringList(PREF_RECENT_KEYWORD) ?? [];
    return keywordList;
  }

  static void setLanguage(int langUid, BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (gLang != langUid) {
      gLang = langUid;
      context.setLocale(Locale(getLang(gLang)));
    }

    prefs.setInt(PREF_LANG, langUid);
  }

  static Future<int> getLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PREF_LANG) ?? 0;
  }
}
