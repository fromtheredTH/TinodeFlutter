
import 'dart:convert';
import 'dart:io';

// import 'package:app/models/GameModel.dart';
// import 'package:app/models/MentionModel.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tinodeflutter/dto/file_dto.dart';
import 'package:tinodeflutter/global/global.dart';
// import 'package:firebase_auth/firebase_auth.dart';

import '../Constants/ImageUtils.dart';
import '../helpers/common_util.dart';
// import '../models/User.dart';
// import '../models/dto/file_dto.dart';

class DioClient {

  static const String communityBaseUrl = "https://comm.jade-chat.com/api/v1"; // 커뮤니티 실서버
  static const String platformBaseUrl = "https://api.jade-chat.com/api/v1"; // 플랫폼 실서버

  static const String tinodeUrl = "http://$hostAddres";

  static Dio getInstance(String baseUrl) {
    Dio dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 30),
          validateStatus: (status) {
            return status! <= 400;
          },
        )
    );
    dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          String x_tinode_token = "Token $token";
          if(token.isNotEmpty) {
            // options.headers["Authorization"] = token;
            options.headers["X-Tinode-Auth"] = x_tinode_token;
            options.headers["X-Tinode-Apikey"] = apiKey;
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (response.statusCode == 400) {
            showToast(response.data["error"]["message"]);
            return handler.reject(
                DioException(requestOptions: response.requestOptions));
          } else {
            return handler.next(response);
          }
        },
        onError: (DioError e, handler) async {
          print("::: Api error : $e");

          if (e.response == null) {
            showToast("taost_nework_unable".tr());
          } else {
            try {
              print(e.response?.requestOptions.path);
            } catch (error) {

            }
            try {
              String errorMsg = e.response?.data["message"];
                showToast(errorMsg);
              return;
            } catch (errMsg) {
              print(errMsg);
            }
          }
          return handler.next(e);
        }));
    return dio;
  }

  static Dio getInstancePost(String baseUrl) {
    Dio dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 30),
          validateStatus: (status) {
            return status! <= 400;
          },
        )
    );
    dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          // String token = "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}";
          String x_tinode_token = "Token $token";
          if(token.isNotEmpty) {
            options.headers["X-Tinode-Auth"] = x_tinode_token;
            options.headers["X-Tinode-Apikey"] = apiKey;
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (response.statusCode == 400) {
            return handler.reject(
                DioException(requestOptions: response.requestOptions));
          } else {
            return handler.next(response);
          }
        },
        onError: (DioError e, handler) async {
          print("::: Api error : $e");

          if (e.response == null) {
            showToast("taost_nework_unable".tr());
          } else {
            try {
              print(e.response?.requestOptions.path);
            } catch (error) {

            }
            try {
              String errorMsg = e.response?.data["message"];
              // showToast(errorMsg);
              return handler.reject(
                  DioException(requestOptions: e.requestOptions));
            } catch (errMsg) {
              print(errMsg);
            }
          }
          return handler.next(e);
        }));
    return dio;
  }

  static Future<Response> getTimelineUsers(String channelId, int size, int page) {
    Map<String, dynamic> queryData = {
      "limit": size,
      "offset": page*size
    };
    return getInstance(communityBaseUrl).get("/timeline/users/$channelId", queryParameters: queryData);
  }

  static Future<Response> getTimelineGames(String gamePath, int size, int page) {
    Map<String, dynamic> queryData = {
      "limit": size,
      "offset": page*size
    };
    return getInstance(communityBaseUrl).get("/timeline/games/$gamePath", queryParameters: queryData);
  }


  static Future<Response> searchTotal(String query, int limit, int page) {
    Map<String, dynamic> queryData = {
      "q" : query,
      "limit" : limit,
      "offset" : page*limit
    };
    return getInstance(communityBaseUrl).get("/search", queryParameters: queryData);
  }

  static Future<Response> searchPosts(String query, int limit, int page) {
    print("최초 검색어 \"$query\"");
    String posts = "";
    String hash = "";
    List<String> splits = query.split("#");
    if(splits.length == 1){
      posts = splits[0];
    }else{
      posts = splits[0];
      posts = posts.replaceAll(RegExp('[^a-zA-Z0-9가-힣_\\s]'), "");
      splits.removeAt(0);
      hash = splits.join("#");
      hash = hash.replaceAll(RegExp('[^a-zA-Z0-9가-힣_]'), "");
      hash = hash.replaceAll(" ", "");
    }
    print("포스팅 \"$posts\", 해쉬 \"$hash\"");
    Map<String, dynamic> queryData = {
      "posting" : posts,
      "hashtag" : hash,
      "limit" : limit,
      "offset" : page*limit
    };
    print(queryData.toString());
    return getInstance(communityBaseUrl).get("/search", queryParameters: queryData);
  }

  static Future<Response> searchGame(String query, int limit, int page) {
    Map<String, dynamic> queryData = {
      "gametitle" : query,
      "limit" : limit,
      "offset" : page*limit
    };
    return getInstance(communityBaseUrl).get("/search", queryParameters: queryData);
  }

  static Future<Response> getChatUpdate(int lastId) {
    Map<String, dynamic> queryData = {
      "last_read_chat_id" : lastId
    };
    return getInstance(communityBaseUrl).get("/chat/updated-rooms", queryParameters: queryData);
  }

  static Future<Response> getChatRoom(int id) {
    return getInstance(communityBaseUrl).get("/chat/$id/info");
  }

  static Future<Response> getChatRoomList(int limit, int page) {
    Map<String, dynamic> queryData = {
      "limit" : limit,
      "offset" : page*limit
    };
    return getInstance(communityBaseUrl).get("/chat/rooms", queryParameters: queryData);
  }

  static Future<Response> searchCommunity(String query, int limit, int page) {
    Map<String, dynamic> queryData = {
      "community" : query,
      "limit" : limit,
      "offset" : page*limit
    };
    return getInstance(communityBaseUrl).get("/search", queryParameters: queryData);
  }

  static Future<Response> searchUsers(String query, int limit, int page) {
    Map<String, dynamic> queryData = {
      "username" : query,
      "limit" : limit,
      "offset" : page*limit
    };
    return getInstance(communityBaseUrl).get("/search", queryParameters: queryData);
  }
  static Future<Response> postUserFollow(int userId) {
    final formData = jsonEncode({
      "target_user_id": userId
    });
    return getInstance(communityBaseUrl).post("/user/follow", data: formData);
  }


  static Future<Response> getPost(String postId){
    return getInstancePost(communityBaseUrl).get("/post/$postId");
  }


  static Future<Response> checkNickname(String nickname) {
    final formData = jsonEncode({
      "nickname":nickname
    });
    return getInstance(platformBaseUrl).post("/user/has-nickname", data: formData);
  }

  static Future<Response> checkEmail(String email) {
    final formData = jsonEncode({
      "email":email
    });
    return getInstance(platformBaseUrl).post("/user/has-email", data: formData);
  }

  static Future<Response> getTranslationList() {
    return getInstance(platformBaseUrl).get("/lang-list");
  }

  static Future<Response> signUp(String nickname, String name) {
    final formData = jsonEncode({
      "nickname":nickname,
      "name" : name
    });
    return getInstance(platformBaseUrl).post("/user/sign-up", data: formData);
  }

  static Future<Response> getBgList() {
    return getInstance(platformBaseUrl).get("/post-bg");
  }

  static Future<Response> getUserQR() {
    return getInstance(platformBaseUrl).get("/user/qr");
  }

  static Future<Response> getNotification(int limit, int offset, String date) {
    Map<String, dynamic> queryData = {
      "limit" : limit,
      "offset" : offset,
      "from" : date
    };
    return getInstance(communityBaseUrl).get("/notification",queryParameters: queryData);
  }

  static Future<Response> getUser(String nickname) {
    return getInstance(platformBaseUrl).get("/user/$nickname");
  }
  static Future<Response> getMyInfo() {
    return getInstance(platformBaseUrl).get("/user/info");
  }
  static Future<Response> updateUserProfile(File? profileFile, File? bannerFile, bool? rmPicture, bool? rmBanner) async {

    Dio dio = getInstance(platformBaseUrl);
    dio.options.contentType = "multipart/form-data";

    final dataMap = <String,dynamic>{};

    if(profileFile != null){
      File sendFile = await ImageUtils.resizeImageFile(profileFile);
      dataMap["file"] = MultipartFile.fromFileSync(sendFile.path);
    }

    if(bannerFile != null){
      File sendFile = await ImageUtils.resizeImageFile(bannerFile);
      dataMap["banner_file"] = MultipartFile.fromFileSync(sendFile.path);
    }
    if(rmPicture != null) {
      dataMap["rm_picture"] = rmPicture;
    }
    if(rmBanner != null) {
      dataMap["rm_banner"] = rmBanner;
    }

    FormData formData = FormData.fromMap(dataMap);


    return dio.post("/user/update/info", data: formData);
  }

  static Future<Response> settingQuestion(String text, String email) {
    final formDataMap = {
      "text":text,
      "email":email
    };
    FormData formData = FormData.fromMap(formDataMap);
    return getInstance(platformBaseUrl).post("/support/inquiry", data: formData);
  }

  static Future<Response> getBlockUsers(int limit, int page){
    Map<String, dynamic> queryData = {
      "limit" : limit,
      "offset" : page*limit
    };
    return getInstance(communityBaseUrl).get("/user/block-list", queryParameters: queryData);
  }

  static Future<Response> userUnBlock(int userId) {
    return getInstance(communityBaseUrl).post("/member/$userId/unblock");
  }


  static Future<Response> reportUser(int id, String enums, String reason) {
    final formDataMap = {
      "target_id": id,
      "reason_num":enums,
      "reason":reason
    };
    FormData formData = FormData.fromMap(formDataMap);
    return getInstance(platformBaseUrl).post("/report/user", data: formData);
  }

  static Future<Response> getChatRoomFromMessage(int id) {

    return getInstance(communityBaseUrl).get("/messages/$id");
  }

  // static Future<Response> deleteNotification(int id) {

  //   return getInstance(communityBaseUrl).delete("/notification/$id");
  // }

  static Future<Response> niceCertify() async {
    var response = await getInstance(platformBaseUrl).get("/user/auth/certify");
    return response;
  }

  static Future<Response> getVersion() async {
    return getInstance(platformBaseUrl).get("/version");
  }

  static Future<Response> setFCM(String token, String deviceId) async {
    final formData = jsonEncode({
      "token": token,
      "device_id":deviceId
    });
    return getInstance(communityBaseUrl).post("/fcm", data: formData);
  }

static Future<Response> deleteFCM(String token) async {
    Map<String, dynamic> queryData = {
      "token": token
    };
    return getInstance(communityBaseUrl).delete("/fcm", queryParameters: queryData);
  }
  static Future<Response> getItemList(int storeType) {
    Map<String, int> queryData = {
      "store_type": storeType
    };
    return getInstance(platformBaseUrl).get("/items", queryParameters: queryData);
  }

  static Future<Response> postIapReceipt(dynamic receipt) {
    // final formDataMap = {
    //   "receipt": receipt
    // };
    // FormData formData = FormData.fromMap(formDataMap);

    return getInstance(platformBaseUrl).post("/payment/iap", data: receipt);
  }
  
  static Future<Response> getMembershipData() {
    return getInstance(platformBaseUrl).get("/user/membership");
  }

  static Future<Response> postChatRoomClear(int room_id) {

    return getInstance(communityBaseUrl).post("/chat/rooms/$room_id/clear");
  }
  static Future<Response> postUpdateChatExpire(int room_id, int timer) {
  final formDataMap = {
      "idx": timer, 
    }; //time / idx 0 : 타이머 비활성(무제한 유지) 
   
    return getInstance(communityBaseUrl).post("/chat/rooms/$room_id/update-expire", data : formDataMap);
  }

  static Future<Response> getFirstMessageData(int size, int page) {
    Map<String, dynamic> queryData = {
      "limit": size,
      "offset": page*size
    };
    return getInstance(communityBaseUrl).get("/chat/rooms/first-message", queryParameters: queryData);
  }
  static Future<Response> getUserInfoById(String ids) {
    Map<String, dynamic> queryData = {
      "user_ids": ids,
    };
    return getInstance(communityBaseUrl).get("/user/other/infos?user_ids", queryParameters: queryData);
  }

static Future<Response> postDeleteAccount(String reason) {

  final formDataMap = {
      "num": 0, 
      "text":reason
    }; 
    return getInstance(platformBaseUrl).post("/user/delete-account", data : formDataMap);
  }

  

  static Future<Response> postUploadFile(String filePath) async {
    Dio dio = getInstance(tinodeUrl);
    dio.options.contentType = "multipart/form-data";

    File file = File(filePath);
    String fileName = filePath.split('/').last;

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
      "id": 1,
    });

    return dio.post("/v0/file/u/", data: formData);
  }


  static Future<Response> uploadPosting(String content, List<FileDto> files,) {
    final dataMap = <String,dynamic>{};
    
    dataMap["contents"] = content.isNotEmpty ? content : null;
    if(files.isNotEmpty) {
      dataMap["attatchment_files"] = files.map((e) => e.toJson()).toList();
    }

    final formData = jsonEncode(dataMap);
    return getInstance(communityBaseUrl).post("/post", data: formData);
  }
 
static Future<Response> getAgoraToken(String channelName, String token ) {

    Map<String, dynamic> queryData = {
      // "id":1,
      "channel": channelName, 
      "auth":"auth",
      "secret" :token,
      "role" :1
    };
    return getInstance(tinodeUrl).get("/v0/agora/token", queryParameters : queryData);
  }



}