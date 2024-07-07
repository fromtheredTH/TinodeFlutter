import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tinodeflutter/global/global.dart';
import 'messageRoomListScreen.dart';
import '../tinode/tinode.dart';
import '../tinode/src/models/message.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:http/http.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

import '../../components/item/PositionRetainedScrollPhysics.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_it/get_it.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.title});

  final String title;
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late Tinode tinode;

  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();

  String id = "";
  String pw = "";

  String versionApp = '1.0.0';
  String deviceLocale = 'en-US';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connectWsTinode();
  }

  void connectWsTinode() async{
   var key = apiKey;
    var host = hostAddres;
    var loggerEnabled = true;
    tinode = Tinode(
      'JadeChat',
      ConnectionOptions(host, key, secure: false),
      loggerEnabled,
      versionApp: versionApp,
      deviceLocale: deviceLocale,
    );
    await tinode.connect();
    tinode_global = tinode;
    print('Is Connected:' + tinode.isConnected.toString());

  }

  void loginProcesss() async {

    id = idController.value.text == "" ? "test3" : idController.value.text;
    pw = pwController.value.text == "" ? "qwer123!" : pwController.value.text;
 
  try {
      var result = await tinode.loginBasic(id, pw, null);
      print('User Id: ' + result.params['user'].toString());
      token = result.params['token'];
      url_encoded_token = Uri.encodeComponent(result.params['token']);
      print("token : $token");
      print("url token : $url_encoded_token");
      showToast("login 완료");
      Get.offAll(MessageRoomListScreen(
        tinode: tinode,
      ));
    } catch (err) {
      showToast("잘못 입력했습니다");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(children: [
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black)),
            padding:
                const EdgeInsets.only(left: 20, top: 12, bottom: 12, right: 10),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: idController,
                  cursorColor: Colors.black,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  onEditingComplete: () {},
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.center,
                  textInputAction: TextInputAction.done,
                  maxLength: 50,
                  decoration: InputDecoration(
                      counterText: "",
                      contentPadding: EdgeInsets.zero,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintText: 'input id',
                      isDense: true,
                      hintStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                      border: InputBorder.none),
                  onChanged: (text) {
                    setState(() {});
                  },
                ),
              ),
            ]),
          ),
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black)),
            padding:
                const EdgeInsets.only(left: 20, top: 12, bottom: 12, right: 10),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: pwController,
                  cursorColor: Colors.black,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  onEditingComplete: () {},
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.center,
                  textInputAction: TextInputAction.done,
                  maxLength: 50,
                  decoration: InputDecoration(
                      counterText: "",
                      contentPadding: EdgeInsets.zero,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintText: 'pw input',
                      isDense: true,
                      hintStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                      border: InputBorder.none),
                  onChanged: (text) {
                    setState(() {});
                  },
                ),
              ),
            ]),
          ),
          SizedBox(
            // SizedBox 대신 Container를 사용 가능
            width: 100,
            height: 40,
            child: FilledButton(
              onPressed: () {
                loginProcesss();
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Text('login'),
            ),
          ),
        ]),
      ),
    );
  }
}
