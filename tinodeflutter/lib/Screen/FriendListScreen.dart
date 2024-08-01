import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:tinodeflutter/Constants/Constants.dart';
import 'package:tinodeflutter/Constants/ImageUtils.dart';
import 'package:tinodeflutter/Constants/RouteString.dart';
import 'package:tinodeflutter/Screen/BottomNavBarScreen.dart';
import 'package:tinodeflutter/Screen/ProfileScreen.dart';
import 'package:tinodeflutter/Screen/SearchUser.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/components/widget/UserListItemWidget.dart';
import 'package:tinodeflutter/components/focus_detector.dart';
import 'package:tinodeflutter/components/widget/loading_widget.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/page/base/base_state.dart';
import 'package:tinodeflutter/tinode/tinode.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';

class FriendListScreen extends StatefulWidget {
  FriendListScreen({
    Key? key,
    // required this.changePage, required this.onTapLogo,
     required this.friendScreenInitController
  });
  // Function(String, String) changePage;
  // String? hashTag;
  // Function() onTapLogo;
   InitController friendScreenInitController;
  @override
  State<FriendListScreen> createState() => _FriendListScreenState(friendScreenInitController);
}

// class _FriendListScreen extends BaseState<FriendListScreen> {
class _FriendListScreenState extends BaseState<FriendListScreen> {
  _FriendListScreenState(InitController friendScreenInitController){
    friendScreenInitController.initHome = initHome;
  }
  late TopicFnd _fndFriendTopic;

  void initHome() {
    setState(() {
      isSearchMode = false;
      searchController.text = "";
    });
  }

  late Topic me;

  bool isShowKeyboard = false;
  TextEditingController searchController = TextEditingController();
  String previousSearchText = "";
  bool isSearchMode = false;
  bool isSearchLoading = false;
  RxBool isExistSearchText = false.obs;
  bool isLoading = false;
  ScrollController scrollController = ScrollController();
  bool hasPostNextPage = false;
  int discoverPage = 0;

  String? hashTag;

  List<UserModel> userList = <UserModel>[];
  List<UserModel> _friendList = <UserModel>[];
  List<TopicSubscription> userTopicSubList = <TopicSubscription>[];
  StreamSubscription? _metaSubscription;

  @override
  void initState() {
    // hashTag = widget.hashTag;
    super.initState();
    me = tinode_global.getMeTopic();
    _getFriendList();
    _initializeFndTopic();
  }
      @override
  void dispose() {
    if(_metaSubscription!=null) _metaSubscription?.cancel();
    _fndFriendTopic.leave(true); 
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    return super.didChangeAppLifecycleState(state);
  }

   void _initializeFndTopic() async{
    _fndFriendTopic = tinode_global.getTopic('fnd') as TopicFnd;
    _metaSubscription= _fndFriendTopic.onMeta.listen((value) {
      _handleFriendMetaMessage(value);
    });
    if(!_fndFriendTopic.isSubscribed) await _fndFriendTopic.subscribe(MetaGetBuilder(_fndFriendTopic).withData(null, null, null).build(), null);
  }

  void _handleFriendMetaMessage(MetaMessage msg) {
    if (msg.sub != null) {
        try{
        print("search list :");
        for(int i = 0 ; i<msg.sub!.length ;i++)
        {
          String pictureUrl = msg.sub?[i].public['photo']?['ref'] != null ? changePathToLink(msg.sub?[i].public['photo']['ref']) : "";
          UserModel user = UserModel(id: msg.sub?[i].user ?? "" , name : msg.sub?[i].public['fn'], picture : pictureUrl, isFreind: msg.sub?[i].isFriend ?? false);
          _friendList.add(user);
        }
        setState(() {
          isSearchLoading = false;
        });
        }
        catch(err)
        {
          print("err : $err");
        }
    }
  }

  Future<void> _searchFriend(String query) async {
    try {
      searchController.text="";
      // SetParams 객체를 생성하여 검색 쿼리 설정
      String friendQuery = "friend:$query";
      SetParams setParams = SetParams(
        desc: TopicDescription(
          public: friendQuery, // 유저 이름을 검색 키워드로 설정
        ),
      );
      // fnd 토픽에 메타데이터 설정 요청 보내기
      var ctrl = await _fndFriendTopic.setMeta(setParams);

   // GetQuery 객체를 생성하여 검색 결과 요청
    GetQuery getQuery = GetQuery(
      topic : _fndFriendTopic.name,
      what: 'sub',
    );
    // fnd 토픽에 메타데이터 요청 보내기
    _friendList = [];
    var meta = await _fndFriendTopic.getMeta(getQuery);

    } catch (err) {
      print("err search : $err");
      isLoading=false;
    }
  }

  Future<void> _getFriendList() async {
    GetQuery getQuery = GetQuery(
      what: 'fri',
    );
    try {
      var data = await me.getMeta(getQuery);
      if (data.fri != null) {
        for (int i = 0; i < data.fri.length; i++) {
          String pictureUrl = data.fri?[i].public['photo']?['ref'] != null
              ? changePathToLink(data.fri[i].public['photo']['ref'])
              : "";
          UserModel user = UserModel(
              id: data.fri[i].user,
              name: data.fri[i].public['fn'],
              picture: pictureUrl, isFreind: true);
          //_friendList.add(user);
          setState(() {
          _friendList.add(user);
          });
        }
      }
    } catch (err) {
      print("get freind list : $err");
    }
  }

  Future<void> _delFriend(String userid) async {
    try{
      var data = await tinode_global.friMeta(userid, 'del');
      showToast('친구 삭제 완료');
    }
    catch(err)
    {
      print("delete err : $err");
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
                                text: "대화 상대",
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 16,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: InkWell(
                                onTap: () {
                                  Get.to(SerachUserScreen());
                                  // Navigator.of(context).push(
                                  //   SwipeablePageRoute(
                                  //     canOnlySwipeFromEdge: true,
                                  //     builder: (context) => MessageRoomAddScreen(),
                                  //   ),
                                  // ).then((value) {});
                                },
                                child: SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: Icon(
                                    Icons.person_add,
                                    size: 25,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
  }

  Widget _searchWidget()
  {
    return  Padding(
                      padding: EdgeInsets.only(
                          right: Get.width * 0.02, left: Get.width * 0.02),
                      child: Container(
                          width: Get.width, // Set width according to your needs
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                                6.0), // Adjust the value as needed
                          ),
                          margin: EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: TextFormField(
                                  controller: searchController,
                                  onFieldSubmitted: (text) {
                                    // widget.changePage(RouteString.disvoerSearch, text);
                                  },
                                  onChanged: (text) {
                                    isSearchLoading = true;
                                    if (previousSearchText.isEmpty &&
                                        text.isNotEmpty) {
                                      setState(() {
                                        isSearchMode = true;
                                      });
                                      _searchFriend(text);
                                      isExistSearchText.value = true;
                                    } else if (previousSearchText.isNotEmpty &&
                                        text.isEmpty) {
                                      setState(() {
                                        isSearchMode = false;
                                      });
                                    } else {
                                      print("검색");
                                      print(text);
                                      print(searchController.text);
                                      _searchFriend(text);
                                      isExistSearchText.value = true;
                                    }
                                    previousSearchText = text;
                                  },
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: FontConstants.AppFont,
                                      fontSize: 16),
                                  textInputAction: TextInputAction.search,
                                  decoration: InputDecoration(
                                    hintText: '친구 검색',
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical:
                                            12.0), // Adjust vertical padding
                                    border: InputBorder.none,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: ImageUtils.setImage(ImageConstants.chatSearchWhite, 10, 10, color: Colors.grey),
                                    ),
                                    // Align hintText to center
                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: FontConstants.AppFont,
                                        fontSize: 14),
                                    // alignLabelWithHint: true,
                                  ),
                                ),
                              ),
                              Obx(() => isExistSearchText.value
                                  ? GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isExistSearchText.value = false;
                                          searchController.text = "";
                                          previousSearchText = "";
                                          isSearchMode = false;
                                        });
                                      },
                                      child: ImageUtils.setImage(
                                          ImageConstants.searchX, 20, 20),
                                    )
                                  : Container()),
                              SizedBox(
                                width: 10,
                              )
                            ],
                          )),
                    );
  }



  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight =
        size.width * 0.4 * 1.8; // Adjust the fraction as needed
    final double itemWidth = size.width * 0.4;

    return FocusDetector(
        onFocusLost: () {},
        onFocusGained: () {
          setState(() {});
        },
        child: GestureDetector(
            onTap: FocusScope.of(context).unfocus,
            child: Scaffold(
              backgroundColor: ColorConstants.backgroundGrey,
              resizeToAvoidBottomInset: true,
              body: Padding(
                padding: EdgeInsets.only(
                    right: Get.width * 0.01, left: Get.width * 0.01),
                child: Column(
                  children: [
                    SizedBox(height: Get.height * 0.04),
                    _topBarWidget(),
                    // Padding(
                    //     padding: EdgeInsets.only(left: 10, right: 10),
                    //     child: CustomTitleBar(callBack: (){
                    //       Get.to(ProfileScreen(user: Constants.user, tinode: tinode,));
                    //     },onTapLogo: (){
                    //       widget.onTapLogo();
                    //     },)),
                    // SizedBox(height: Get.height * 0.02),
                    _searchWidget(),
                    // 친구리스트 보여지는 영역
                    isSearchMode
                        ? Expanded(
                            child: isSearchLoading
                                ? LoadingWidget()
                                : _friendList.isEmpty
                                    ? Center(
                                        child: AppText(
                                          text: "empty_search".tr(),
                                          fontSize: 13,
                                          color: ColorConstants.gray3,
                                        ),
                                      )
                                    : Container(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: SingleChildScrollView(
                                          
                                          child: Column(
                                            children: [                                           
                                              _friendList.isNotEmpty? 
                                              Column(
                                                      children: [                                                      
                                                        ListView.builder(
                                                            shrinkWrap: true,
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            itemCount:
                                                                _friendList
                                                                    .length,
                                                            itemBuilder:
                                                                (context,index) {
                                                              Key key = Key(
                                                                  _friendList[index].id.toString());
                                                              return UserListItemWidget(
                                                                key: key,
                                                                user:_friendList[index],
                                                                isShowAction:
                                                                    true,
                                                                    unFollowUser: (){
                                                                      _delFriend(_friendList[index].id);
                                                                       setState(() {
                                                                    _friendList.removeAt(index);
                                                                  });
                                                                    },
                                                                deleteUser: () {
                                                                  setState(() {
                                                                    _friendList.removeAt(index);
                                                                  });
                                                                },
                                                              );
                                                            }),
                                                      ],
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                      ))
                        : Expanded(
                            child: isSearchLoading
                                ? LoadingWidget()
                                : _friendList.length == 0
                                    ? Center(
                                        child: AppText(
                                          text: "친구가 없습니다.",
                                          fontSize: 13,
                                          color: Colors.black,
                                        ),
                                      )
                                    : Container(
                                        padding: EdgeInsets.only(
                                            top:10,
                                            left: 10, right: 10),
                                            color: Colors.white,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                             
                                              _friendList.isNotEmpty
                                                  ? Column(
                                                      children: [                                                    
                                                        ListView.builder(
                                                            shrinkWrap: true,
                                                            physics: NeverScrollableScrollPhysics(),
                                                            itemCount: _friendList.length,
                                                            itemBuilder: (context,index) {
                                                              Key key = Key(_friendList[index].id.toString());
                                                              return UserListItemWidget(
                                                                key: key,
                                                                user: _friendList[index],
                                                                isShowAction: true,
                                                                unFollowUser:(){
                                                                  _delFriend(_friendList[index].id);
                                                                   setState(() {
                                                                    _friendList.removeAt(index);
                                                                  });
                                                                },
                                                                deleteUser: () {
                                                                  setState(() {
                                                                    _friendList.removeAt(index);
                                                                  });
                                                                },
                                                              );
                                                            }),
                                                      ],
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                      )
                         
                            ),
                    SizedBox(height: Constants.navBarHeight,),
                  ],
                ),
              ),
            )));
  }
}
