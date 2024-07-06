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
      {super.key, required this.tinode, this.roomTopic, this.existUserList});
  Tinode tinode;
  Topic? roomTopic;
  late TopicFnd _fndTopic;

  List<User>? existUserList;

  @override
  State<MessageRoomAddScreen> createState() => _MessageRoomAddScreenState();
}

class _MessageRoomAddScreenState extends State<MessageRoomAddScreen> {
  late Tinode tinode;
  Topic? roomTopic;
  late Topic me;
  late TopicFnd _fndTopic;

  List<User> friendList = [];
  List<User> selectList = [];
  List<User> searchUserList = [];

  bool isInit = false;
  bool isSearchingLoading = false;
  bool isSearchComplete = false;

  TextEditingController searchTextController = TextEditingController();
  TextEditingController nameTextController = TextEditingController();

  ScrollController userScrollController = ScrollController();
  ScrollController mainScrollController = ScrollController();

  bool hasNextPage = false;

  late FocusNode _focusNode;

  late Topic _groupTopic;
  late Topic _1to1Topic;

  bool is1to1 = false;

  @override
  void initState() {
    super.initState();
    tinode = widget.tinode;
    _focusNode = FocusNode();
    roomTopic = widget.roomTopic;
    me = tinode.getMeTopic();

    mainScrollController = ScrollController()..addListener(onScroll);
    searchTextController.addListener(searchUser);
    _initializeFndTopic();
    _getFriendList();

    Future.delayed(Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void searchUser() {
    if (!isSearchComplete) {
      setState(() {
        searchUserList.clear();
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
    _fndTopic = tinode.getTopic('fnd') as TopicFnd;
    _fndTopic.onMeta.listen((value) {
      _handleMetaMessage(value);
    });
    if (!_fndTopic.isSubscribed)
      await _fndTopic.subscribe(
          MetaGetBuilder(_fndTopic).withData(null, null, null).build(), null);
  }

  void _handleMetaMessage(MetaMessage msg) {
    if (msg.sub != null) {
      setState(() {
        try {
          print("search list :");
          for (int i = 0; i < msg.sub!.length; i++) {
            String pictureUrl = msg.sub?[i].public['photo']?['ref'] != null
                ? changePathToLink(msg.sub?[i].public['photo']['ref'])
                : "";
            User user = User(
                id: msg.sub?[i].user ?? "",
                name: msg.sub?[i].public['fn'],
                picture: pictureUrl,
                isFreind: msg.sub?[i].isFriend ?? false);
            searchUserList.add(user);
          }
          
            isLoading = false;
            isSearchingLoading = false;
          
        } catch (err) {
          print("err : $err");
        }
      });
    } else {
      setState(() {
        isLoading = false;
        isSearchingLoading = false;
      });
    }
  }

  Future<void> _searchUsers(String query) async {
    try {
      // SetParams 객체를 생성하여 검색 쿼리 설정
      SetParams setParams = SetParams(
        desc: TopicDescription(
          public: query, // 유저 이름을 검색 키워드로 설정
        ),
      );
      // fnd 토픽에 메타데이터 설정 요청 보내기
      var ctrl = await _fndTopic.setMeta(setParams);

      // GetQuery 객체를 생성하여 검색 결과 요청
      GetQuery getQuery = GetQuery(
        topic: _fndTopic.name,
        what: 'sub',
        //sub: GetOptsType(user: query), // 적절한 GetOptsType 설정
      );
      // fnd 토픽에 메타데이터 요청 보내기
      var meta = await _fndTopic.getMeta(getQuery);
      if (meta?.text == "no content") {
        setState(() {
          isLoading = false;
          isSearchingLoading = false;
        });
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
    tinode.getFndTopic();
  }

  Future<void> _getFriendList() async {
    GetQuery getQuery = GetQuery(
      what: 'fri',
    );
    try {
      var data = await me.getMeta(getQuery);
      isInit = true;

      if (data.fri != null) {
        friendList.clear();
        for (int i = 0; i < data.fri.length; i++) {
          String pictureUrl = data.fri?[i].public['photo']?['ref'] != null
              ? changePathToLink(data.fri[i].public['photo']['ref'])
              : "";
          User user = User(
              id: data.fri[i].user,
              name: data.fri[i].public['fn'],
              picture: pictureUrl,
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
        () => MessageRoomScreen(tinode: tinode, clickTopic: selectList[0].id));
  }

  Future<void> onClickMakeRoom() async {
    if (selectList.isEmpty) return;
    if (widget.existUserList != null && (roomTopic?.name?[0] ?? "") == 'g') {
      // 안 들어오면 방에서 초대한게 아니라 새로운 채팅방 만들고 있는것
      await inviteUserToGroup();
      return;
    }
    isSearchComplete = true;

    // 여러명일때는 그룹으로
    // 한명일때는 p2P로
    is1to1 ? _1to1Room() : makeGroupRoom();
  }

  void createGroupChat() async {
    // 새로운 그룹 토픽을 생성
    var newTopic = tinode.newTopic();
    // 토픽의 메타데이터 설정
    var setParams = SetParams(
      desc: TopicDescription(
        public: {'fn': 'openChat', 'description': 'This is a public channel'},
        //defacs: DefAcs(auth: 'JRWPAS', anon: 'RWP'),
      ),
      tags: ['public', 'channel'],
    );

    // 토픽 구독 요청
    await tinode.subscribe(newTopic.name.toString(), GetQuery(), setParams);

    // 구독 성공 후 추가 작업 (예: 초기 메시지 보내기)
  }

  Future<void> makeGroupRoom() async {
    String groupName = "MyGroup"; // 예시 그룹 이름
    try {
      // 새로운 그룹 토픽 이름 생성
      tinode.newGroupTopicName(true);

      // 새로운 토픽 인스턴스 생성
      _groupTopic = tinode.newTopic();

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
          tinode: tinode, clickTopic: _groupTopic.name ?? ""));
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

  @override
  Widget build(BuildContext context) {
    return PageLayout(
        onBack: onBackPressed,
        isLoading: isLoading,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              Container(
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
                            child: Image.asset(ImageConstants.backWhite,
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
                                    ? Colors.white
                                    : selectList.length < 2
                                        ? Colors.white
                                        : ColorConstants.halfWhite,
                                fontSize: 16),
                            border: InputBorder.none),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 65,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 0, bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: ColorConstants.white10Percent),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(ImageConstants.chatSearchWhite,
                          height: 24, width: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: searchTextController,
                          cursorColor: Colors.black,
                          focusNode: _focusNode,
                          style: TextStyle(
                            color: Colors.white,
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
                                  color: ColorConstants.halfWhite,
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
              ),
              selectList.length >= 1
                  ? Container(
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
                                                  text: selectList[index].id ??
                                                      '샘플 닉네임',
                                                  fontSize: 12,
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
                    )
                  : Container(),
              searchTextController.text.isEmpty
                  ? Expanded(
                      child: isInit
                          ? SingleChildScrollView(
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
                                                          .colorMain)),
                                              const SizedBox(width: 20),
                                              AppText(
                                                text: searchTextController
                                                        .text.isEmpty
                                                    ? '친구목록'
                                                    : "add_chat_search",
                                                fontSize: 10,
                                                color: ColorConstants.colorMain,
                                              ),
                                              const SizedBox(width: 20),
                                              Expanded(
                                                  child: Container(
                                                      height: 0.51,
                                                      color: ColorConstants
                                                          .colorMain)),
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
                          : Expanded(
                              child: Center(
                                child: SizedBox(
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          color: ColorConstants.colorMain)),
                                  height: 20.0,
                                  width: 20.0,
                                ),
                              ),
                            ),
                    )
                  : Expanded(
                      child: isSearchingLoading
                          ? Center(
                              child: SizedBox(
                                child: Center(
                                    child: CircularProgressIndicator(
                                        color: ColorConstants.colorMain)),
                                height: 20.0,
                                width: 20.0,
                              ),
                            )
                          : searchUserList.isNotEmpty
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ItemUser(
                                      user: searchUserList[index],
                                      selected: selectList
                                          .map((item) => item.id)
                                          .contains(searchUserList[index].id),
                                      isDisabled: widget.existUserList
                                              ?.map((item) => item.id)
                                              .contains(
                                                  searchUserList[index].id) ??
                                          false,
                                      onClick: () {
                                        setState(() {
                                          if (selectList
                                              .map((user) => user.id)
                                              .contains(
                                                  searchUserList[index].id)) {
                                            for (int i = 0;
                                                i < selectList.length;
                                                i++) {
                                              if (selectList[i].id ==
                                                  searchUserList[index].id) {
                                                selectList.removeAt(i);
                                                break;
                                              }
                                            }
                                          } else {
                                            selectList
                                                .add(searchUserList[index]);
                                          }
                                        });
                                      },
                                    );
                                  },
                                  itemCount: searchUserList.length)
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
                                ? 'new_chat'.tr(args: ["${selectList[0].id}"])
                                : 'new_group_chat'
                                    .tr(args: ["${selectList.length}"]),
                        fontWeight: FontWeight.w700,
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
