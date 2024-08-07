import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tinodeflutter/Constants/ColorConstants.dart';
import 'package:tinodeflutter/Constants/FontConstants.dart';
import 'package:tinodeflutter/Constants/ImageConstants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tinodeflutter/Screen/SearchUser.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:http/http.dart';
import 'package:tinodeflutter/components/item/item_user.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:get/get.dart' hide Trans;
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/page/base/base_state.dart';
import 'package:tinodeflutter/page/base/page_layout.dart';

import '../components/item/PositionRetainedScrollPhysics.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_it/get_it.dart';

import '../tinode/tinode.dart';
import 'messageRoomScreen.dart';

class MessageRoomAddScreen extends StatefulWidget {
  MessageRoomAddScreen(
      {super.key,  this.roomTopic, this.existUserList});
  Topic? roomTopic;
 // late TopicFnd _fndMessageAddUserTopic;

  List<UserModel>? existUserList;

  @override
  State<MessageRoomAddScreen> createState() => _MessageRoomAddScreenState();
}

class _MessageRoomAddScreenState extends BaseState<MessageRoomAddScreen> {
  Topic? roomTopic;
  late Topic me;
  late TopicFnd _fndMessageAddUserTopic;

  List<UserModel> friendList = [];
  List<UserModel> selectList = [];
  List<UserModel> _searchUserList = [];

  bool isInit = false;
  bool isSearchingLoading = false;
  bool isSearchComplete = false;

  TextEditingController searchTextController = TextEditingController();
  TextEditingController nameTextController = TextEditingController();

  ScrollController userScrollController = ScrollController();
  ScrollController mainScrollController = ScrollController();
  
  StreamSubscription? _metaSubscription;

  bool hasNextPage = false;

  late FocusNode _focusNode;

  late Topic _groupTopic;
  late Topic _1to1Topic;

  bool is1to1 = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    roomTopic = widget.roomTopic;
    me = tinode_global.getMeTopic();
    isInit = true;

    mainScrollController = ScrollController()..addListener(onScroll);
    searchTextController.addListener(searchUser);
    _initializeFndTopic();
    _getFriendList();

    // 키보드 자동 띄우기
    // Future.delayed(Duration(milliseconds: 100), () {
    //   FocusScope.of(context).requestFocus(_focusNode);
    // });
  }

  @override
  void dispose() {
    if(_metaSubscription!=null) _metaSubscription?.cancel();
    _fndMessageAddUserTopic.leave(true); 
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    return super.didChangeAppLifecycleState(state);
  }

  

  void searchUser() {
    if (!isSearchComplete) {
      setState(() {
        _searchUserList.clear();
        if (searchTextController.text.isNotEmpty) {
          isSearchingLoading = true;
          _searchUsers(searchTextController.text);
        }
      });
    }
  }

  void onScroll() {
    if (!isLoading) {
      if (mainScrollController.position.pixels ==
          mainScrollController.position.maxScrollExtent) {
        if (!hasNextPage) {
          return;
        }
        if (searchTextController.text.isEmpty) {
          _getFriendList();
        } else {
          _searchUsers(searchTextController.text);
        }
      }
    }
  }

  void _initializeFndTopic() async {
   _fndMessageAddUserTopic = tinode_global.getTopic('fnd') as TopicFnd;
    _metaSubscription = _fndMessageAddUserTopic.onMeta.listen((value) {
      _handleMetaMessage(value);
    });
    if (!_fndMessageAddUserTopic.isSubscribed)
      await _fndMessageAddUserTopic.subscribe(
          MetaGetBuilder(_fndMessageAddUserTopic).withData(null, null, null).build(), null);
  }

  void _handleMetaMessage(MetaMessage msg) {
    if (msg.sub != null) {
        try{
        print("search list :");
        for(int i = 0 ; i<msg.sub!.length ;i++)
          {
            bool hasPublic=true;
            if(msg.sub?[i].public ==null) hasPublic=false;
            UserModel user =UserModel(id: msg.sub?[i].user ?? '', 
            name: hasPublic? (msg.sub?[i].public['fn'] ?? "") : "", 
            picture: hasPublic? (msg.sub?[i].public['photo']!=null ? (msg.sub?[i].public['photo']['ref']!=null ? (msg.sub?[i].public['photo']['ref'] ?? "" ) : (msg.sub?[i].public['photo'] ?? "")):""): "", 
            isFreind: msg.sub?[i].isFriend ?? false);
            print("user :  ${hasPublic? (msg.sub?[i].public['fn']) : ""}  count: $i  photourl: ${user.picture}");

            // String pictureUrl = msg.sub?[i].public['photo']?['ref'] != null ? changePathToLink(msg.sub?[i].public['photo']['ref']) : "";
            // UserModel user = UserModel(id: msg.sub?[i].user ?? "" , name : msg.sub?[i].public['fn'], picture : pictureUrl, isFreind: msg.sub?[i].isFriend ?? false);
            _searchUserList.add(user);
          }
          setState(() {
                  isLoading = false;
            isSearchingLoading = false;
          
          });
        }
        catch(err)
        {
          print("err : $err");
        }
    }
    else{ showToast('검색한 유저가 없습니다.');
          isLoading = false;
            isSearchingLoading = false;
          setState(() {
            
          });
    }
   }

  Future<void> _searchUsers(String query) async {
    isInit = false;

    try {
      // SetParams 객체를 생성하여 검색 쿼리 설정
      SetParams setParams = SetParams(
        desc: TopicDescription(
          public: query, // 유저 이름을 검색 키워드로 설정
        ),
      );
      // fnd 토픽에 메타데이터 설정 요청 보내기
      var ctrl = await _fndMessageAddUserTopic.setMeta(setParams);

      // GetQuery 객체를 생성하여 검색 결과 요청
      GetQuery getQuery = GetQuery(
        topic: _fndMessageAddUserTopic.name,
        what: 'sub',
        //sub: GetOptsType(user: query), // 적절한 GetOptsType 설정
      );
      // fnd 토픽에 메타데이터 요청 보내기
      var meta = await _fndMessageAddUserTopic.getMeta(getQuery);

       if(meta.runtimeType==CtrlMessage){
          if(meta.text !=null && meta.text =="no content") 
            {
              showToast('해당 유저는 친구가 아닙니다.');
               setState(() {
                isLoading = false;
                isSearchingLoading = false;
          });
        }
        }else{
          //_handleFriendMetaMessage(meta);
        }
    
    } catch (err) {
      print("err search : $err");
      setState(() {
        isLoading = false;
        isSearchingLoading = false;
      });
    }
  }

  void onClickSearchUser(String inputString) {
    if (inputString.isEmpty) {
      showToast("내용입력");
      return;
    }
    tinode_global.getFndTopic();
  }

  Future<void> _getFriendList() async {
    GetQuery getQuery = GetQuery(
      what: 'fri',
    );
    try {
      var data = await me.getMeta(getQuery);
      if(data.text =="no content") return;
      if (data.fri != null) {
        friendList.clear();
        for (int i = 0; i < data.fri.length; i++) {
          bool hasPublic=true;
            if(data.fri?[i].public ==null) hasPublic=false;
            UserModel user =UserModel(id: data.fri?[i].user ?? '', 
            name: hasPublic? (data.fri?[i].public['fn'] ?? "") : "", 
            picture: hasPublic? (data.fri?[i].public['photo']!=null ? (data.fri?[i].public['photo']['ref']!=null ? (data.fri?[i].public['photo']['ref'] ?? "" ) : (data.fri?[i].public['photo'] ?? "")):""): "", 
            isFreind: true);
          //friendList.add(user);
          setState(() {
            friendList.add(user);
          });
        }
      }
    } catch (err) {
      print("get freind list : $err");
    }
  }

  void _1to1Room() {
    Get.off(
        () => MessageRoomScreen(clickTopic: selectList[0].id));
  }

  Future<void> onClickMakeRoom() async {
    if (selectList.isEmpty) return;
    if (widget.existUserList != null && roomTopic!=null && roomTopic!.isGroup()) {
      // 안 들어오면 방에서 초대한게 아니라 새로운 채팅방 만들고 있는것
      await inviteUserToGroup();
      return;
    }
    isSearchComplete = true;

    is1to1 =  selectList.length > 1 ? false : true;

    // 여러명일때는 그룹으로
    // 한명일때는 p2P로
    is1to1 ? _1to1Room() : makeGroupRoom();
  }

  void createGroupChat() async {
    // 새로운 그룹 토픽을 생성
    var newTopic = tinode_global.newTopic();
    // 토픽의 메타데이터 설정
    var setParams = SetParams(
      desc: TopicDescription(
        public: {'fn': 'openChat', 'description': 'This is a public channel'},
        //defacs: DefAcs(auth: 'JRWPAS', anon: 'RWP'),
      ),
      tags: ['public', 'channel'],
    );

    // 토픽 구독 요청
    await tinode_global.subscribe(newTopic.name.toString(), GetQuery(), setParams);

    // 구독 성공 후 추가 작업 (예: 초기 메시지 보내기)
  }

  Future<void> makeGroupRoom() async {
    String groupName =nameTextController.text; // 예시 그룹 이름
    if(groupName =="") groupName = "그룹방";
    try {
      // 새로운 그룹 토픽 이름 생성
      tinode_global.newGroupTopicName(true);

      // 새로운 토픽 인스턴스 생성
      _groupTopic = tinode_global.newTopic();

      // 구독 요청
      await _groupTopic?.subscribe(
          MetaGetBuilder(_groupTopic).withData(null, null, null).build(), null);

      print('Group chat created: $groupName');

      // 메타 데이터 설정
      TopicDescription desc = TopicDescription(
          public: {'fn': groupName, 'description': 'This is a private group'},
          defacs: DefAcs('JRWPAS', ''));
      try {
        // 사용자 초대용 초기 설정
        // TopicSubscription sub = TopicSubscription(
        //   user: 'usrEiSwIao9WvQ',
        //   //mode: 'JRWPAS',
        // );
        SetParams setParams = SetParams(
          desc: desc,
          //sub: sub,
          tags: ['public', 'group'],
        );
        await _groupTopic?.setMeta(setParams);

        print('Meta data updated for group chat: $groupName');
        // 새로운 사용자를 그룹에 초대
        inviteUserToGroup();
      } catch (e) {
        print("err sub : $e");
      }

      // 메타 데이터 설정 후 추가 작업 (예: 메시지 전송, 사용자 초대 등)
      // _groupTopic?.onData.listen((value) {
      //   print("come");
      //   if (value != null) print("groupTopic value : ${value.content}");
      // });
    } catch (e) {
      print('Failed to create group chat: $e');
    }
  }

  Future<void> inviteUserToGroup() async {
    try {
      // AccessMode 객체 생성
      // int modeInt = AccessMode.decode('JRWPAS') ?? 0; // 문자열을 정수로 변환
      // AccessMode accessMode = AccessMode(modeInt); // 정수로 AccessMode 초기화
      // String mode = accessMode.getMode() ?? "";

      // 사용자 초대
      for (int i = 0; i < selectList.length; i++) {
        await _groupTopic.invite(selectList[i].id, 'JRWPAS');
      }
      _groupTopic.leave(true);
      Get.off(() => MessageRoomScreen(
           clickTopic: _groupTopic.name ?? ""));
      print('User  invited to group chat');
    } catch (e) {
      print('Failed to invite user to group chat: $e');
    }
  }

  // Future<void> makeGroupRoom() async {
  //   String groupName = "";
  //   try {
  //     tinode.newGroupTopicName(true);
  //     _groupTopic = tinode.newTopic();

  //     await _groupTopic.subscribe(
  //         MetaGetBuilder(_groupTopic).withData(null, null, null).build(), null);
  //     print('Group chat created: $groupName');

  //     _groupTopic.onData.listen((value) {
  //       print("come");
  //       if (value != null) print("groupTopic value : ${value.content}");
  //     });

  //     // = (data) {
  //     //   setState(() {
  //     //     _messages.add(data.content['txt']);
  //     //   });
  //     // };
  //     Get.back();
  //     Get.to(()=>MessageRoomScreen(tinode: tinode, clickTopic: _groupTopic.name.toString()));
  //   } catch (e) {
  //     print('Failed to create group chat: $e');
  //     Get.back();
  //   }
  // }

  void inviteUser(List<String> members) {}

  Future<bool> onBackPressed() async {
    Navigator.pop(context);
    return false;
  }

  Widget topBar() {
    return Container(
                height: 64,
                child: Row(
                  children: [
                    InkWell(
                      onTap: onBackPressed,
                      child: Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(left: 10),
                          child: Center(
                            child: Image.asset(ImageConstants.backWhite,color: Colors.black,
                                width: 24, height: 24),
                          )),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextField(
                        controller: nameTextController,
                        cursorColor: Colors.white,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontFamily: FontConstants.AppFont,
                          fontSize: 16,
                        ),
                        onEditingComplete: () => {},
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.center,
                        textInputAction: TextInputAction.search,
                        enabled: widget.existUserList != null ||
                                selectList.length < 2
                            ? false
                            : true,
                        decoration: InputDecoration(
                            counterText: "",
                            contentPadding: EdgeInsets.zero,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            hintText: widget.existUserList != null
                                ? "멤버 추가"
                                : selectList.length < 2
                                    ? '새 채팅'
                                    : "새로운 그룹 채팅방",
                            isDense: true,
                            hintStyle: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontFamily: FontConstants.AppFont,
                                color: widget.existUserList != null
                                    ? Colors.black
                                    : selectList.length < 2
                                        ? Colors.black
                                        : ColorConstants.halfBlack,
                                fontSize: 16),
                            border: InputBorder.none),
                      ),
                    )
                  ],
                ),
              );
  }

  Widget searchUserBox(){
    return Container(
                height: 65,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 0, bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
          //             border: Border(
          //   bottom: BorderSide(
          //     color: Colors.black, // 선의 색상
          //     width: 2.0, // 선의 두께
          //   ),
          // ),
                  color: ColorConstants.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(ImageConstants.chatSearchWhite, color: Colors.grey,
                          height: 24, width: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: searchTextController,
                          cursorColor: Colors.black,
                          focusNode: _focusNode,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontFamily: FontConstants.AppFont,
                            fontSize: 14,
                          ),
                          onEditingComplete: () => {},
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                              counterText: "",
                              contentPadding: EdgeInsets.zero,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              hintText: '채팅할 유저를 검색하세요',
                              isDense: true,
                              hintStyle: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: FontConstants.AppFont,
                                  color: ColorConstants.backGryText,
                                  fontSize: 14),
                              border: InputBorder.none),
                        ),
                      ),
                      if (searchTextController.text.isNotEmpty)
                        Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    searchTextController.text = "";
                                  });
                                },
                                child: Image.asset(ImageConstants.circleBlackX,
                                    height: 20, width: 20)))
                    ],
                  ),
                ),
              );
  }

  Widget _selectedUsersBar()
  {
    return Container(
                      height: 25,
                      margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                      child: Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              controller: userScrollController,
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (!selectList[index].selected) {
                                                selectList[index].selected =
                                                    true;
                                              } else {
                                                selectList[index].selected =
                                                    false;
                                                selectList
                                                    .remove(selectList[index]);
                                              }
                                            });
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(right: 10),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                color: selectList[index]
                                                        .selected
                                                    ? Colors.black
                                                    : ColorConstants.colorMain),
                                            child: Row(
                                              children: [
                                                AppText(
                                                  text: selectList[index].name ??
                                                      '샘플 닉네임',
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                                if (selectList[index].selected)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 4),
                                                    child: Image.asset(
                                                        ImageConstants
                                                            .circleWhiteBlackX,
                                                        height: 16,
                                                        width: 16),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      itemCount: selectList.length),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );//select list >=1 이상일때
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
        onBack: onBackPressed,
        isLoading: isLoading,
        bgColor: ColorConstants.backgroundGrey,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              topBar(),
              searchUserBox(),
              
              selectList.length >= 1
                  ? _selectedUsersBar()
                  : Container(),  //select list ==0 일때

              searchTextController.text.isEmpty
                  ? Expanded(
                      child: 
                       Container(
                         padding: EdgeInsets.only(top:10,left: 10, right: 10),
                         color: Colors.white,
                          child:
                          // isInit?
                           SingleChildScrollView(
                              controller: mainScrollController,
                              child: Column(
                                children: [
                                  if (friendList.isNotEmpty)
                                    Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                  child: Container(
                                                      height: 0.5,
                                                      color: ColorConstants
                                                          .black)),
                                              const SizedBox(width: 20),
                                              AppText(
                                                text: searchTextController
                                                        .text.isEmpty
                                                    ? '친구'
                                                    : "add_chat_search",
                                                fontSize: 12,
                                                fontWeight:  FontWeight.w700,
                                                color: ColorConstants.black,
                                              ),
                                              const SizedBox(width: 20),
                                              Expanded(
                                                  child: Container(
                                                      height: 0.51,
                                                      color: ColorConstants
                                                          .black)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  friendList.isEmpty
                                      ? Container(
                                          width: double.maxFinite,
                                          height: 100,
                                          child: Center(
                                            child: AppText(
                                              text: "친구가 없습니다.",
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return ItemUser(
                                              user: friendList[index],
                                              selected: selectList
                                                  .map((item) => item.id)
                                                  .contains(
                                                      friendList[index].id),
                                              isDisabled: widget.existUserList
                                                      ?.map((item) => item.id)
                                                      .contains(
                                                          friendList[index]
                                                              .id) ??
                                                  false,
                                              onClick: () {
                                                setState(() {
                                                  if (selectList
                                                      .map((user) => user.id)
                                                      .contains(
                                                          friendList[index]
                                                              .id)) {
                                                    for (int i = 0;
                                                        i < selectList.length;
                                                        i++) {
                                                      if (selectList[i].id ==
                                                          friendList[index]
                                                              .id) {
                                                        selectList.removeAt(i);
                                                        break;
                                                      }
                                                    }
                                                  } else {
                                                    selectList
                                                        .add(friendList[index]);
                                                  }
                                                });
                                              },
                                            );
                                          },
                                          itemCount: friendList.length)
                                ],
                              ),
                            )
                          // : Expanded(  //isInit이 false일때
                          //     child: Center(
                          //       child: SizedBox(
                          //         child: Center(
                          //             child: CircularProgressIndicator(
                          //                 color: ColorConstants.colorMain)),
                          //         height: 20.0,
                          //         width: 20.0,
                          //       ),
                          //     ),
                          //   ),
                       ),
                    ) // 여기까지 searchTextController is empty : true , 여기 밑에는 false
                  : Expanded(
                      child: isSearchingLoading
                          ?
                          Container(
                            padding: EdgeInsets.only( top:10, left: 10, right: 10),
                            color: Colors.white,
                            child: Center(
                              child: SizedBox(
                                child: Center(
                                    child: CircularProgressIndicator(
                                        color: ColorConstants.colorMain)),
                                height: 20.0,
                                width: 20.0,
                              ),
                            )

                          ) 
                         
                          : _searchUserList.isNotEmpty
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ItemUser(
                                      user: _searchUserList[index],
                                      selected: selectList
                                          .map((item) => item.id)
                                          .contains(_searchUserList[index].id),
                                      isDisabled: widget.existUserList
                                              ?.map((item) => item.id)
                                              .contains(
                                                  _searchUserList[index].id) ??
                                          false,
                                      onClick: () {
                                        setState(() {
                                          if (selectList
                                              .map((user) => user.id)
                                              .contains(
                                                  _searchUserList[index].id)) {
                                            for (int i = 0;
                                                i < selectList.length;
                                                i++) {
                                              if (selectList[i].id ==
                                                  _searchUserList[index].id) {
                                                selectList.removeAt(i);
                                                break;
                                              }
                                            }
                                          } else {
                                            selectList
                                                .add(_searchUserList[index]);
                                          }
                                        });
                                      },
                                    );
                                  },
                                  itemCount: _searchUserList.length)
                              : Container(
                                  width: double.maxFinite,
                                  height: 100,
                                  child: Center(
                                    child: AppText(
                                      text: "add_chat_search_empty".tr(),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                    ),
              if (selectList.length > 0)
                GestureDetector(
                  onTap: () {
                    onClickMakeRoom();
                  },
                  child: Container(
                    width: double.maxFinite,
                    height: 47,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        
                        color: ColorConstants.colorMain),
                    child: Center(
                      child: AppText(
                        text: widget.existUserList != null
                            ? "add_chat_user".tr(args: ["${selectList.length}"])
                            : selectList.length == 1
                                ? 'new_chat'.tr(args: ["${selectList[0].name}"])
                                : 'new_group_chat'
                                    .tr(args: ["${selectList.length}"]),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ));
  }
}
