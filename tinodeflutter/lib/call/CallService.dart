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



class CallService extends GetxService {
  CallService({Key? key, required this.joinUserList, required this.roomTopicName});
  List<User> joinUserList;
  String roomTopicName;
  final FlutterCallkitIncoming _callKit = FlutterCallkitIncoming();
  final Uuid _uuid = Uuid();
  late Topic roomTopic;

  @override
  void onInit() {
    super.onInit();
    if(!tinode_global.isConnected) {reConnectTinode(afterConnectFunc: ()=>{
        if(!roomTopic.isSubscribed) {
            setRoomTopic() 
        }
        else{
          _initializeCallKit()
        }
      });
    }
    else{
      if(!roomTopic.isSubscribed) {
        setRoomTopic(); 
      }
      else{
      _initializeCallKit();
      }
    }
    
  }

  Future<void> setRoomTopic()async{
    roomTopic = tinode_global.getTopic(roomTopicName);
     try {
      if (!roomTopic.isSubscribed) {
        await roomTopic.subscribe(MetaGetBuilder(roomTopic).withData(null, null, null).withSub(null, null, null).withDesc(null).build(), null);
        _initializeCallKit();      
        }
    } catch (err) {
      print("err roomTopic set Callservice : $err");
    }
  }
  
void _initializeCallKit() {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      if (event == null) return;

      try{
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
            Get.to(()=>CallScreen(tinode: tinode_global,joinUserList:joinUserList));
            break;
          case Event.actionCallAccept:
            // 전화 수락 처리
            print("Call accepted");
            // 방에대해 구독을 하고 accepted 를 날려줘야함.
            noteCallState('accepted');
            nowCallState = eCallState.ACCEPTED;
            Get.to(() => CallScreen(tinode: tinode_global,joinUserList:joinUserList));
            break;
          case Event.actionCallDecline:
            // 전화 거절 처리
            nowCallState = eCallState.DECLINED;
            noteCallState('declined');
            print("Call declined");
            break;
          default:
            print("Unhandled event: ${event.event}");
            break;
        }
      }
      catch(err)
      {
        print(" init call kit err : $err");
      }
        
    });
  }
  void noteCallState(String callState)
  {
    Map<String,dynamic> note= {
        "event":callState,
        "seq" : 1,
        "topic": roomTopic.name,
        "what" :"call",
       };
    tinode_global.note(roomTopic.name ?? "", "call" , 1, callState);
    
  }

  Future<void> showIncomingCall({
    required String callerName,
    String? callerNumber,
    String? callerAvatar,
  }) async {
    final String callId = _uuid.v4();
    final params = CallKitParams(
      id: callId,
      nameCaller: callerName,
      appName: 'JadeChat',
      avatar: callerAvatar,
      handle: callerNumber,
      type: 0,
      duration: 150000,
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
              callerName: 'John Doe',
              callerNumber: '',
            );
          },
        ),
      ),
    );
  }
}


