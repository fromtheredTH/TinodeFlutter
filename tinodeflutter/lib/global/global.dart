//user level
// const String API_COMMUNITY_URL = "https://api-extn-com.zempie.com/api/v1";
// const String API_PLATFORM_URL = "https://api-extn-pf.zempie.com/api/v1";
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:tinodeflutter/tinode/tinode.dart';

const String API_COMMUNITY_URL = "https://comm.jade-chat.com/api/v1";
const String API_PLATFORM_URL = "https://api.jade-chat.com/api/v1";

int gLang = 0; //Overall language: if isLogin user.lang else local_service.lang
String gPushKey = "";
int gPushClickMsgId=-1;
int gChatRoomUid = 0;
int gCurrentId = 0;
bool gPushClick = false;

const apiKey = "AQAAAAABAAC5Ym2pu9wKC_cbu2omxbD6";
const hostAddres = "3.37.226.251:6060";

const String agoraAppId = "895be24bd60746d381158b444eb4902c";

// const apiKey = "AQAAAAABAADON7Kp-RdTKZPIsJU9CoWc"; // 영락님 로컬 서버
// const hostAddres = "192.168.0.26:6060";  // 영락님 로컬 서버

String token ="";
String url_encoded_token ="";

bool isLoading=false;

late Tinode tinode_global;

String gBackgroundFcmTopic="";

  String id = "";
  String pw = "";

  String versionApp = '1.0.0';
  String deviceLocale = 'en-US';

  Future<bool> reConnectTinode({Function? afterConnectFunc}) async {
    var key = apiKey;
    // var host = 'sandbox.tinode.co';
    var host = hostAddres;
    id =  "test3";
    pw = 'qwer123!';

    var loggerEnabled = true;
    tinode_global = Tinode(
      'JadeChat',
      ConnectionOptions(host, key, secure: false),
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
}
eCallState nowCallState = eCallState.NONE;
