import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:get/get.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/tinode/src/meta-get-builder.dart';
import 'package:tinodeflutter/tinode/src/topic.dart';
import 'package:uuid/uuid.dart';

import 'CallController.dart';
import 'CallScreen.dart';

class CallService {
  CallService(
      {Key? key, required this.joinUserList, required this.roomTopicName , required this.chatType});

  static CallService? _instance;
  static CallService get instance => _getOrCreateInstance();
  static CallService _getOrCreateInstance() {
    if (_instance != null) {
      return _instance!;
    }
    _instance = CallService(joinUserList: [], roomTopicName: "", chatType: eChatType.NONE);
    return _instance!;
  }

  List<UserModel> joinUserList;
  String roomTopicName;
  eChatType chatType;
  final FlutterCallkitIncoming _callKit = FlutterCallkitIncoming();
  final Uuid _uuid = Uuid();
  late Topic roomTopic;

  bool isInit = false;

  Future<bool> initCallService() async{
    try {
      if (!tinode_global.isConnected) {
        bool isResult=false;
        await reConnectTinode(afterConnectFunc: () async {
          }   
        );
           isResult = await setRoomTopic();
            //_initializeCallKit();
            return isResult;
      } else {
        return await setRoomTopic();
        if (!isInit) {
         // _initializeCallKit();
        }
      }
      isInit = true;
    } catch (err) {
      print(" callservice init call service err : $err");
      return false;
    }
    return false;
  }

  // @override
  // void onInit() {
  //   super.onInit();

  // }

  Future<bool> setRoomTopic() async {
    roomTopic = tinode_global.getTopic(roomTopicName);
    try {
      if (!roomTopic.isSubscribed) {
        await roomTopic.subscribe(
            MetaGetBuilder(roomTopic)
                .withData(null, null, null)
                .withSub(null, null, null)
                .withDesc(null)
                .build(),
            null);
        _initializeCallKit();
        return true;
      }else {
        _initializeCallKit();
        return true;
      }
    } catch (err) {
      print("err roomTopic set Callservice : $err");
      return false;
    }
  }

  void _initializeCallKit() {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      if (event == null) return;

      try {
        switch (event.event) {
          case Event.actionCallIncoming:
            // 수신 전화 처리
            nowCallState = eCallState.INCOMING;
            print("Incoming call");
            break;
          case Event.actionCallStart:
            // 수신 전화 처리
            nowCallState = eCallState.START;
            print("call start");
            if (Get.currentRoute != '/CallScreen') {
                  Get.to(() => CallScreen(
                      tinode: tinode_global, joinUserList: joinUserList, chatType: chatType,));
                }
            break;
          case Event.actionCallAccept:
            // 전화 수락 처리
            print("Call accept");
            // 방에대해 구독을 하고 accept 를 날려줘야함.
            try {
            noteCallState('accept');
            nowCallState = eCallState.ACCEPTED;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
            Get.to(()=>CallScreen(tinode: tinode_global, roomTopic: roomTopic ,joinUserList: joinUserList,chatType: chatType,));
            });
                print("eee");
            } catch (err) {
              print("accepted err $err");
            }

            break;
          case Event.actionCallDecline:
            // 전화 거절 처리
            nowCallState = eCallState.DECLINED;
            noteCallState('hang-up');
            print("Call declined");
            break;
          default:
            print("Unhandled event: ${event.event}");
            break;
        }
      } catch (err) {
        print(" init call kit err : $err");
      }
    });
  }

  void noteCallState(String callState) {
    Map<String, dynamic> note = {
      "event": callState,
      "seq": 1,
      "topic": roomTopic.name,
      "what": "call",
    };
    try{
      tinode_global.note(roomTopic.name ?? "", "call", 1, callState);

    }
    catch(err)
    {
      print("note err");
    }
  }

  Future<void> showIncomingCall({
    required String roomTopicId,
    required String callerName,
    String? callerNumber,
    String? callerAvatar,
  }) async {
    final String callId = _uuid.v4();
    final params = CallKitParams(
      id: roomTopicId,
      nameCaller: callerName,
      appName: 'JadeChat',
      avatar: callerAvatar,
      handle: callerNumber,
      type: 0, // 0 : 오디오 1: 비디오
      duration: 60000,  //miliseconds
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      extra: <String, dynamic>{'userId': 'user_id'},
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);

  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: ElevatedButton(
          child: Text('Simulate Incoming Call'),
          onPressed: () {
            Get.find<CallService>().showIncomingCall(
              roomTopicId: "1",
              callerName: 'John Doe',
              callerNumber: '',
            );
          },
        ),
      ),
    );
  }
}
