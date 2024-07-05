//user level
// const String API_COMMUNITY_URL = "https://api-extn-com.zempie.com/api/v1";
// const String API_PLATFORM_URL = "https://api-extn-pf.zempie.com/api/v1";
const String API_COMMUNITY_URL = "https://comm.jade-chat.com/api/v1";
const String API_PLATFORM_URL = "https://api.jade-chat.com/api/v1";

int gLang = 0; //Overall language: if isLogin user.lang else local_service.lang
String gPushKey = "";
int gPushClickMsgId=-1;
int gChatRoomUid = 0;
int gCurrentId = 0;
bool gPushClick = false;

const apiKey = "AQAAAAABAAC5Ym2pu9wKC_cbu2omxbD6";
const hostAddres = "54.180.163.159:6060";
String token ="";
String url_encoded_token ="";

bool isLoading=true;


enum eChatType {
  NONE,
  TEXT,
  IMAGE,
  VIDEO,
  AUDIO,
  VOICE_CALL,
  VIDEO_CALL,
  HTML,
  SYSTEM,
}
