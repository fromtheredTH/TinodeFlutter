//user level
// const String API_COMMUNITY_URL = "https://api-extn-com.zempie.com/api/v1";
// const String API_PLATFORM_URL = "https://api-extn-pf.zempie.com/api/v1";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tinodeflutter/Screen/SplashScreen.dart';
import 'package:tinodeflutter/Screen/messageRoomListScreen.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:tinodeflutter/tinode/tinode.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String API_COMMUNITY_URL = "https://comm.jade-chat.com/api/v1";
const String API_PLATFORM_URL = "https://api.jade-chat.com/api/v1";

int gLang = 0; //Overall language: if isLogin user.lang else local_service.lang
String gPushKey = "";
int gPushClickMsgId=-1;
String gCurrentTopic = "";
String gCurrentId = "";
bool gPushClick = false;
bool isMessageRoom=false;

const apiKey = "AQAAAAABAAC5Ym2pu9wKC_cbu2omxbD6";
const hostAddres = "api.jade-chat.com";
// const hostAddres = "3.37.226.251:6060";

const String agoraAppId = "895be24bd60746d381158b444eb4902c";

// const apiKey = "AQAAAAABAADON7Kp-RdTKZPIsJU9CoWc"; // 영락님 로컬 서버
// const hostAddres = "192.168.0.26:6060";  // 영락님 로컬 서버

String token ="";
String url_encoded_token ="";

bool isConnectProcessing_global = false;
int pingMiliSeconds = 0;
PublishSubject<int> pingSubject = PublishSubject<int>();


bool isLoading=false;

late Tinode tinode_global;

String gBackgroundFcmTopic="";

  String id = "";
  String pw = "";

  String versionApp = '1.0.0';
  String deviceLocale = 'ko_KR';

 Future<bool> reLogin() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      if (prefs.getInt('login_type') == 0) // 0 : id , pw  // 1: firebase
      {
        id_pw_Login(prefs);
        return true;
      } else if (prefs.getInt('login_type') == 1) {
        // firebase
        firebaseLogin(prefs);
        return true;
      }
      showToast('여기는 들어오는 곳 아님');
      return false; // 여기는 들어오면 안됨
    } catch (err) {
      print("re login err : $err");
      showToast('re login err  $err');
      return false;
    }
  }

  void firebaseLogin(SharedPreferences prefs) async {
    User? user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        String firebaseToken =
            "${await FirebaseAuth.instance.currentUser?.getIdToken()}";
        // print("firebase login token : $firebaseToken ");
        if (token != "") {
          var response = await tinode_global.firebaseLogin(firebaseToken);
          token = response.params['token'];
          url_encoded_token = Uri.encodeComponent(response.params['token']);
          prefs.setString('token', token);
          prefs.setString('url_encoded_token', url_encoded_token);
          showToast('파이어베이스 재 로그인 완료');
            } else {
          print("일로 오면 안돼");
          showToast('파이어베이스 로그인 미구현');
    
          Get.offAll(SplashPage(), transition: Transition.rightToLeft);
        }

        // Constants.getUserInfo(false,context, apiP);
      } catch (e) {
        print(e);
        Get.offAll(SplashPage(), transition: Transition.rightToLeft);
        }
    }
  }

  void id_pw_Login(SharedPreferences prefs) async {
    if (prefs.containsKey('basic_id')) {
      id = prefs.getString('basic_id')!;
    }

    if (prefs.containsKey('basic_pw')) {
      pw = prefs.getString('basic_pw')!;
    }

    try {
      var result = await tinode_global.loginBasic(id, pw, null);
      // print('User Id: ' + result.params['user'].toString());
      token = result.params['token'];
      url_encoded_token = Uri.encodeComponent(result.params['token']);
      prefs.setString('token', token);
      prefs.setString('url_encoded_token', url_encoded_token);
      // print("token : $token");
      // print("url token : $url_encoded_token");
      showToast("relogin 완료");
    } catch (err) {
      showToast("id pw 리 로그인 실패");
      Get.offAll(SplashPage(), transition: Transition.rightToLeft);
    }
  }


// legacy
  Future<bool> reConnectTinode({Function? afterConnectFunc}) async {
    var key = apiKey;
    // var host = 'sandbox.tinode.co';
    var host = hostAddres;
    id =  "test35";
    pw = 'qwer123!';

    final prefs = await SharedPreferences.getInstance();


    var loggerEnabled = true;
    tinode_global = Tinode(
      'JadeChat',
      ConnectionOptions(host, key, secure: true),
      loggerEnabled,
      versionApp: versionApp,
      deviceLocale: deviceLocale,
    );
    await tinode_global.connect();
    print('Is Connected:' + tinode_global.isConnected.toString());

  try {
      var result = await tinode_global.loginBasic(id, pw, null);
      print('User Id: ' + result.params['user'].toString());
      token = result.params['token'];
      url_encoded_token = Uri.encodeComponent(result.params['token']);
      prefs.setString('token', token);
      prefs.setString('url_encoded_token', url_encoded_token);
      
      print("token : $token");
      print("url token : $url_encoded_token");
      showToast("reconnect 완료");
  
      if(afterConnectFunc !=null) afterConnectFunc();
      return true;
    } catch (err) {
      showToast("reconnect err : $err");
      return false;
    }
  }

  


enum eChatType {
  NONE,
  TEXT,
  IMAGE,
  VIDEO,
  AUDIO,
  CALL,
  VOICE_CALL,
  VIDEO_CALL,
  HTML,
  SYSTEM,
}
enum eCallState{
  NONE,
  INCOMING,
  START,
  ACCEPTED,
  DECLINED,
  MISSED,
  DISCONNECTED,
  FINISHED,
}
eCallState nowCallState = eCallState.NONE;
