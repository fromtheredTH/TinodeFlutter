import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:get/get.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';

import 'CallController.dart';
import 'CallScreen.dart';


class CallService extends GetxService {
  final FlutterCallkitIncoming _callKit = FlutterCallkitIncoming();
  final Uuid _uuid = Uuid();

  @override
  void onInit() {
    super.onInit();
    _initializeCallKit();
  }
  
void _initializeCallKit() {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      if (event == null) return;
      
      switch (event.event) {
        case Event.actionCallIncoming:
          // 수신 전화 처리
          print("Incoming call");
          break;
        case Event.actionCallAccept:
          // 전화 수락 처리
          print("Call accepted");
          Get.to(() => CallScreen());
          break;
        case Event.actionCallDecline:
          // 전화 거절 처리
          print("Call declined");
          break;
        default:
          print("Unhandled event: ${event.event}");
          break;
      }
    });
  }

  Future<void> showIncomingCall({
    required String callerName,
    required String callerNumber,
    String? callerAvatar,
  }) async {
    final String callId = _uuid.v4();
    final params = CallKitParams(
      id: callId,
      nameCaller: callerName,
      appName: 'Your App Name',
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
              callerNumber: '1234567890',
            );
          },
        ),
      ),
    );
  }
}


