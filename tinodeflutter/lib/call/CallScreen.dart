import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tinodeflutter/call/CallService.dart';
import 'package:tinodeflutter/call/agoraVoiceCallController.dart';
import 'package:tinodeflutter/global/DioClient.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/tinode/tinode.dart';

import 'CallController.dart';

class CallScreen extends StatefulWidget {
  CallScreen( {super.key, required this.tinode,  this.roomTopic, required this.joinUserList});
  Tinode tinode;
  Topic? roomTopic;
  List<User> joinUserList;
  @override
  State<CallScreen> createState() => _CallScreenState();
}


class _CallScreenState extends State<CallScreen>  {
  late Tinode tinode;
  Topic? roomTopic;
  final CallController controller = Get.put(CallController());
  late List<User> joinUserList;
  

  //agora variable
   int uid = 0; // uid of the local user
    int? _remoteUid; // uid of the remote user
    bool _isJoined = false; // Indicates if the local user has joined the channel
    late RtcEngine agoraEngine; // Agora engine instance
    late final RtcEngineEventHandler _rtcEngineEventHandler;

    final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey
        = GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold
    String channelName = "";
    String agoraToken = "";

     bool isJoined = false,
      openMicrophone = true,
      muteMicrophone = false,
      muteAllRemoteAudio = false,
      enableSpeakerphone = true,
      playEffect = false;
 


  @override
  void initState() {
    super.initState();
    tinode = widget.tinode;
    roomTopic = widget.roomTopic;
    joinUserList = widget.joinUserList;
    initAgora();
  }

// Clean up the resources when you leave
@override
void dispose()  {
     //await agoraEngine.leaveChannel();
     try{
      agoraEngine.unregisterEventHandler(_rtcEngineEventHandler);
      agoraEngine.leaveChannel();
      agoraEngine.release();
     }
     catch(err)
     {
      print("dispose err $err");
     }
    

    super.dispose();
}


  // 채널 네임은 1:1 통화를 건 사람이  상대방 topic 으로 설정함
  // 그룹채팅은 그룹 채팅방을 channel name으로 하면 됨


//agora related function
Future <void> initAgora() async
{ 
  // 1:1 이면 상대방 uid로 채널열기
  try{
    setupVoiceSDKEngine();
    //get agora token
    channelName = sortAndCombineStrings(roomTopic?.name??"", tinode.userId ); //roomTopic?.name??"";
    var response =await DioClient.getAgoraToken(channelName, token);
    agoraToken = response.data?['ctrl']?['params']?['token'];
    uid = response.data?['ctrl']?['params']?['useridx'];
    print("ag token : $agoraToken");
    print("uid $uid");
    //agoraToken ="007eJxTYPjQ4zl5hS+brlZtactRf/WKj3vPsciIL5vuLCUuZ7XAZL4Cg4WlaVKqkUlSipmBuYlZirGFoaGpRZKJiUlqkomlgVGyzbyetIZARgbH+fNYGBkgEMRnYShJLS5hYAAAZyIcMg==";
  }
  catch(err)
  {
    print("agora err : $err");
  }
}

Future<void> setupVoiceSDKEngine() async {
    // retrieve or request microphone permission
    _promptPermissionSetting();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();


    if (roomTopic?.isP2P() ?? true) {
      await agoraEngine.initialize(const RtcEngineContext(
        appId: agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication1v1,
      ));
    } else {
      await agoraEngine.initialize(const RtcEngineContext(
        appId: agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

    }

    // Register the event handler
    _rtcEngineEventHandler =RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        showToast("Local user uid:${connection.localUid} joined the channel");
        setState(() {
            _isJoined = true;
        });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        showToast("Remote user uid:$remoteUid joined the channel");
        setState(() {
            _remoteUid = remoteUid;
        });
        },
        onRemoteAudioStateChanged: (RtcConnection connection, int remoteUid,
          RemoteAudioState state, RemoteAudioStateReason reason, int elapsed) {
            print(
            '[onRemoteAudioStateChanged] connection: ${connection.toJson()} remoteUid: $remoteUid state: $state reason: $reason elapsed: $elapsed');
      },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
        showToast("Remote user uid:$remoteUid left the channel");
        setState(() {
            _remoteUid = null;
        });
        },
        onError: (ErrorCodeType err, String msg) {
        print('[onError] err: $err, msg: $msg');
      },
    );
    agoraEngine.registerEventHandler(_rtcEngineEventHandler);
    await agoraEngine.enableAudio();
   // await agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
   if(roomTopic?.isP2P() ?? true)
   {
      await agoraEngine.setAudioProfile(
      profile: AudioProfileType.audioProfileDefault,
      scenario: AudioScenarioType.audioScenarioDefault,
    ); 
   }else{
      await agoraEngine.setAudioProfile(
      profile: AudioProfileType.audioProfileDefault,
      scenario: AudioScenarioType.audioScenarioChatroom,
    ); 
   }
    _joinChannel();

}

void  _joinChannel() async {

try{
 // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await agoraEngine.joinChannel(
        token: agoraToken,
        channelId: channelName,
        options: options,
        uid: uid,
    );
    showToast('join channel');
}
catch(err)
{
  print("join channel $err");
}
   
}

  void _leaveChannel() {
    setState(() {
        _isJoined = false;
        _remoteUid = null;
    });
    agoraEngine.leaveChannel();
}


  _switchMicrophone() async {
    // await await _engine.muteLocalAudioStream(!openMicrophone);
    await agoraEngine.enableLocalAudio(!openMicrophone);
    setState(() {
      openMicrophone = !openMicrophone;
    });
  }
    void noteCallState(String callState) {
    Map<String, dynamic> note = {
      "event": callState,
      "seq": 1,
      "topic": roomTopic?.name,
      "what": "call",
    };
    try{
      tinode_global.note(roomTopic?.name ?? "", "call", 1, callState);

    }
    catch(err)
    {
      print("note err");
    }
  }


  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS) {
      if (await Permission.microphone.request().isGranted &&
          await Permission.videos.request().isGranted) {
        return true;
      } else {
        await [Permission.microphone].request();
      }
    }
    if (Platform.isAndroid) {
      if (await Permission.microphone.request().isGranted &&
          await Permission.videos.request().isGranted) {
        return true;
      } else {
        await [Permission.microphone].request();
      }
    }
    return false;
  }

Widget _status(){
    String statusText;

    if (!_isJoined){
        statusText = 'Join a channel';
        showToast("join channel");
        }
    else if (_remoteUid == null)
        {statusText = 'Waiting for a remote user to join...';
        showToast("waiting user");}
    else
        {statusText = 'Connected to remote user, uid:$_remoteUid';
        showToast("connect user : $_remoteUid");
        }

    return Text(
    statusText,
    );
}

  @override
  Widget build(BuildContext context) {
   
    return MaterialApp(
          scaffoldMessengerKey: scaffoldMessengerKey,
    home: Scaffold(
      appBar: AppBar(
        title: Text('In Call'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
               Container(
                height: 40,
                child:Center(
                    child:_status()
                )
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // CircleAvatar(
                  //   radius: 50,
                  //   backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                  // ),
                  // SizedBox(height: 20),
                  Text(
                    '${"joinUserList?[0].name ?? """}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Mobile • 00:00',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CallButton(
                    icon: Icons.mic,
                    text: 'Mute',
                    onPressed: (){
                        } //controller.toggleMute,
                  ),
                  CallButton(
                    icon: Icons.dialpad,
                    text: '채널입장',
                    onPressed: (){
                      if(!_isJoined)_joinChannel();
                      else showToast('이미 조인중입니다.');
                        //_switchMicrophone();
                        } //controller.showKeypad,
                  ),
                  CallButton(
                    icon: Icons.volume_up,
                    text: 'Speaker',
                    onPressed: controller.toggleSpeaker,
                  ),
                  CallButton(
                    icon: Icons.call_end,
                    text: 'End',
                    color: Colors.red,
                    onPressed: () {
                      controller.endCall();
                      try{
                        noteCallState('hang-up');
                      }
                      catch(err)
                      {
                        print("err leave : $err");
                      }
                      //_leaveChannel();
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
    );
   
  }
}


class CallButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const CallButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.onPressed,
    this.color = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: text,
          onPressed: onPressed,
          child: Icon(icon),
          backgroundColor: color,
        ),
        SizedBox(height: 8),
        Text(text),
      ],
    );
  }
}

class CallController extends GetxController {
  RxBool isMuted = false.obs;
  RxBool isSpeakerOn = false.obs;

  late AgoraVoiceCallController agoraVoiceCallController ;

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

