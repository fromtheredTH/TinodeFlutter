import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tinodeflutter/Constants/Constants.dart';
import 'package:tinodeflutter/Constants/ImageConstants.dart';
import 'package:tinodeflutter/Constants/ImageUtils.dart';
import 'package:tinodeflutter/Screen/ProfileScreen.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:tinodeflutter/model/MessageRoomModel.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/page/base/base_state.dart';
import 'package:tinodeflutter/page/base/page_layout.dart';
import 'package:tinodeflutter/tinode/src/topic.dart';

class MessageRoomInfoScreen extends StatefulWidget {
  //MessageRoomModel roomData;
  Topic roomTopic;
  List<UserModel> userList;
  MessageRoomInfoScreen({
    super.key,
    required this.roomTopic,
    required this.userList,
    //required this.roomData
  });

  @override
  State<MessageRoomInfoScreen> createState() => _MessageRoomInfoScreenState();
}

class _MessageRoomInfoScreenState extends BaseState<MessageRoomInfoScreen> {
  late MessageRoomModel roomData;
  late Topic roomTopic;
  late List<UserModel> _joinUserList;
  @override
  void initState() {
    // TODO: implement initState
    roomTopic = widget.roomTopic;
    _joinUserList = widget.userList;
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
    try {
      var response = await roomTopic.deleteTopic(true);
      print("room topic delete");
      showToast('채팅방에서 나갔습니다.');
    } catch (err) {
      showToast('delete topic room Err: $err');
    }
  }

  Widget _topBarWidget() {
    return Container(
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

  Widget userWidget(int index) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => {
            // Navigate to ProfileScreen
            // Get.to(ProfileScreen(user: _joinUserList[index]))
          },
          child: ImageUtils.ProfileImage(
            _joinUserList[index].picture != ""
                ? (_joinUserList[index].picture.contains('https://')
                    ? _joinUserList[index].picture
                    : changePathToLink(_joinUserList[index].picture))
                : "",
            43,
            43,
          ),
        ),
        SizedBox(height: 5),
        AppText(
          text: (_joinUserList[index].id == Constants.user.id)
              ? '나'
              : truncateString(_joinUserList[index].name, 6),
        ),
      ],
    );
  }

  Widget _joinUserGridViewWidget() {
    var size = MediaQuery.of(context).size;
    final double itemHeight =
        size.width * 0.4 * 1.8; // Adjust the fraction as needed
    final double itemWidth = size.width * 0.4;
    return Expanded(
      child: GridView.builder(
        padding: EdgeInsets.only(top: 14.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 4 columns
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: (itemWidth / itemHeight)),
        itemCount: _joinUserList.length>= 19 ? 20 : _joinUserList.length ,
        itemBuilder: (context, index) {
          return userWidget(index);
        },
      ),
    );
    //     ,
    //     if (_joinUserList.length > 16) // Show button if more than 16 _joinUserList
    //       Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: ElevatedButton(
    //           onPressed: () {
    //             // Navigate to another page
    //           },
    //           child: Text('더 많은 멤버 보기'),
    //         ),
    //       ),
    //   ],
    // );
  }

  Widget _joinUserListWidget() {
    return Container(
      padding: EdgeInsets.all(14.0),
      color: Colors.white,
      child: Row(children: buildUserColumnsWithSpacingWidget()),
    );
  }

  List<Widget> buildUserColumnsWithSpacingWidget() {
    List<Widget> widgets = [];
    for (int i = 0; i < _joinUserList.length; i++) {
      widgets.add(
        Column(
          children: [
            GestureDetector(
              onTap: () => {Get.to(ProfileScreen(user: _joinUserList[i]))},
              child: ImageUtils.ProfileImage(
                  _joinUserList[i].picture != ""
                      ? (_joinUserList[i].picture.contains('https://')
                          ? _joinUserList[i].picture
                          : changePathToLink(_joinUserList[i].picture))
                      : "",
                  43,
                  43),
            ),
            SizedBox(height: 5),
            AppText(
                text: (_joinUserList[i].id == Constants.user.id)
                    ? '나'
                    : truncateString(_joinUserList[i].name, 6)),
          ],
        ),
      );
      if (i < _joinUserList.length - 1) {
        widgets.add(SizedBox(width: 15));
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
        child: SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        //mainAxisSize: MainAxisSize.min, // Add this line
        children: [
          _topBarWidget(),
          // Header
          //_joinUserListWidget(),
          _joinUserGridViewWidget(),
          SizedBox(height: 10),
          // Options

          // Container(
          //   color: Colors.white,
          //   child: ListTile(
          //         title: Text('기록 검색'),
          //         trailing: Icon(Icons.arrow_forward_ios),
          //       ),),
          // SizedBox(height: 10,),

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
            child: ListTile(
              title: Text('채팅 기록 지우기'),
              onTap: () {},
            ),
          ),
          SizedBox(height: 10),
          Container(
            color: Colors.white,
            child: ListTile(
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
              onTap: () async {
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
    ));
  }
}
