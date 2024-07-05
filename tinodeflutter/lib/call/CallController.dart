

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:tinodeflutter/call/CallService.dart';

class CallController extends GetxController {
  RxBool isMuted = false.obs;
  RxBool isSpeakerOn = false.obs;

  void toggleMute() {
    isMuted.toggle();
    // TODO: 실제 음소거 로직 구현
  }

  void toggleSpeaker() {
    isSpeakerOn.toggle();
    // TODO: 실제 스피커 전환 로직 구현
  }

  void showKeypad() {
    // TODO: 키패드 표시 로직 구현
  }

  void endCall() {
    // TODO: 통화 종료 로직 구현
  }
}

// 푸시 알림을 받았을 때 호출되는 함수
void handlePushNotification(Map<String, dynamic> message) {
  if (message['type'] == 'incoming_call') {
    Get.find<CallService>().showIncomingCall(
      callerName: message['caller_name'],
      callerNumber: message['caller_number'],
      callerAvatar: message['caller_avatar'],
    );
  }
}