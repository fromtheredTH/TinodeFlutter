import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tinodeflutter/Constants/ImageConstants.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:tinodeflutter/model/MessageRoomModel.dart';
import 'package:tinodeflutter/page/base/base_state.dart';
import 'package:tinodeflutter/page/base/page_layout.dart';
import 'package:tinodeflutter/tinode/src/topic.dart';

class MessageRoomInfoScreen extends StatefulWidget {
  //MessageRoomModel roomData;
  Topic roomTopic;
  MessageRoomInfoScreen({super.key, 
  required this.roomTopic,
  //required this.roomData
  });

  @override
  State<MessageRoomInfoScreen> createState() => _MessageRoomInfoScreenState();
}

class _MessageRoomInfoScreenState extends BaseState<MessageRoomInfoScreen> {
  late MessageRoomModel roomData;
  late Topic roomTopic;
  @override
  void initState() {
    // TODO: implement initState
    roomTopic = widget.roomTopic;
   // roomData = widget.roomData;
    super.initState();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    return super.didChangeAppLifecycleState(state);
  }
  
  Future<void> deleteTopic() async // chat room leave
  {
    try{
      var response = await roomTopic.deleteTopic(true);
      print("room topic delete");
      showToast('채팅방에서 나갔습니다.');
    }
    catch(err)
    {
      showToast('delete topic room Err: $err');
    }
  }


   Widget _topBarWidget()
  {
    return  Container(
            height: 56, // AppBar의 기본 높이
            child: Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: AppText(
                      text: "채팅방 상세 정보",
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        Get.back();
                        // Navigator.of(context).push(
                        //   SwipeablePageRoute(
                        //     canOnlySwipeFromEdge: true,
                        //     builder: (context) => MessageRoomAddScreen(),
                        //   ),
                        // ).then((value) {});
                      },
                      child: Container(
                                width: 24,
                                height: 24,
                                //margin: const EdgeInsets.only(left: 10),
                                child: Center(
                                  child: Image.asset(
                                    ImageConstants.backWhite,
                                    width: 24,
                                    height: 24,
                                    color: Colors.black,
                                  ),
                                )),
                    ),
                  ),
                ),
              ],
            ),
          );
           
  }

  Widget _joinUserListWidget()
  {
    return Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.white,
            child: Row(
              children: [
                Column(
                  children: [ 
                    CircleAvatar(),
                    SizedBox(width: 10),
                    Text('Hee'),
                  ],
                ),
              ],
            ),
          );
  }


  @override
  Widget build(BuildContext context) {
      return PageLayout(
      child: Column(
        children: [
          _topBarWidget(),
          // Header
          _joinUserListWidget(),
          SizedBox(height: 10),
          // Options

          Container(
            color: Colors.white,
            child: ListTile(
                  title: Text('기록 검색'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),),
          SizedBox(height: 10,),

          // Container(
          //   color: Colors.white,
          //   child: Column(
          //     children: [
                
          //       SwitchListTile(
          //         title: Text('알림 음소거'),
          //         value: false,
          //         onChanged: (bool value) {},
          //       ),
          //       Divider(height: 1),
          //       SwitchListTile(
          //         title: Text('맨 위에 고정'),
          //         value: false,
          //         onChanged: (bool value) {},
          //       ),
          //       Divider(height: 1),
          //       SwitchListTile(
          //         title: Text('알림'),
          //         value: false,
          //         onChanged: (bool value) {},
          //       ),
          //       // Divider(height: 1),
          //       // ListTile(
          //       //   title: Text('배경'),
          //       //   trailing: Icon(Icons.arrow_forward_ios),
          //       // ),
          //     ],
          //   ),
          // ),
          // SizedBox(height: 10),
          Container(
            color: Colors.white,
            child:
            ListTile(
                  title: Text('채팅 기록 지우기'),
                  onTap: () {},
             ),
          ),
          SizedBox(height: 10),
          Container(
            color: Colors.white,
            child:
            ListTile(
                  title: Text('자동 삭제 조정'),
                  onTap: () {},
             ),
          ),
          // SizedBox(height: 10),
          // Container(
          //   color: Colors.white,
          //   child:
          //   ListTile(
          //         title: Text('신고하기'),
          //         onTap: () {},
          //    ),
          // ),
          SizedBox(height: 10),
          Container(
            color: Colors.white,           
            child: ListTile(
              onTap: () async{
                await deleteTopic();
                Get.back();
                Get.back();
              },
              title: Text(
                '채팅방 나가기',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
