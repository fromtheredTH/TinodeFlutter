import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tinodeflutter/Constants/ColorConstants.dart';
import 'package:tinodeflutter/Constants/Constants.dart';
import 'package:tinodeflutter/Constants/FontConstants.dart';
import 'package:tinodeflutter/Constants/ImageConstants.dart';
import 'package:tinodeflutter/Constants/ImageUtils.dart';
import 'package:tinodeflutter/Screen/ProfileScreen.dart';
import 'package:tinodeflutter/components/focus_detector.dart';
import 'package:tinodeflutter/components/widget/UserListItemWidget.dart';
import 'package:tinodeflutter/components/widget/loading_widget.dart';
import 'package:tinodeflutter/global/global.dart';
import 'messageRoomScreen.dart';
import '../tinode/tinode.dart';
import '../tinode/src/models/message.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:http/http.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

import '../../components/item/PositionRetainedScrollPhysics.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_it/get_it.dart';

import '../model/userModel.dart';

class SerachUserScreen extends StatefulWidget {
  
  SerachUserScreen({super.key, });

  @override
  State<SerachUserScreen> createState() => _SerachUserScreenState();
}

class _SerachUserScreenState extends State<SerachUserScreen> {
  AutoScrollController mainController = AutoScrollController();
  TextEditingController inputController = TextEditingController();
  PositionRetainedScrollPhysics physics = PositionRetainedScrollPhysics();
  List<UserModel> _searchResults = [];
  late TopicFnd _fndSearchUserTopic;
  StreamSubscription? _metaSubscription_SearchUser ;

  String previousUserSearchText = "";
  bool _isUserSearchLoading =false;
  bool _isUserSearchMode =false;
  TextEditingController searchUserController = TextEditingController();
  RxBool isExistUserSearchText = false.obs;

  @override
  void initState() {
    super.initState();
    initializeFndTopic();
  }
    @override
  void dispose() {
    if(_metaSubscription_SearchUser!=null) _metaSubscription_SearchUser?.cancel();
    _fndSearchUserTopic.leave(true); 
    super.dispose();
  }


  String clickTopic = "";
  Future<void> onClickMsgRoom(String clickTopic) async {
    this.clickTopic = clickTopic;
    Get.to(MessageRoomScreen(
      clickTopic: this.clickTopic,
    ));
  }

  void initializeFndTopic() async{
    _fndSearchUserTopic = tinode_global.getTopic('fnd') as TopicFnd;
    _metaSubscription_SearchUser= _fndSearchUserTopic.onMeta.listen((value) {
      _handleMetaMessage(value);
    });
    if(!_fndSearchUserTopic.isSubscribed) await _fndSearchUserTopic.subscribe(MetaGetBuilder(_fndSearchUserTopic).withData(null, null, null).build(), null);
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
            // String pictureUrl = msg.sub?[i].public['photo']?['ref'] != null ? changePathToLink(msg.sub?[i].public['photo']['ref']) : "";
            // UserModel user = UserModel(id: msg.sub?[i].user ?? "" , name : msg.sub?[i].public['fn'], picture : pictureUrl, isFreind: msg.sub?[i].isFriend ?? false);
            _searchResults.add(user);
          }
          setState(() {
            
          });
        }
        catch(err)
        {
          print("err : $err");
        }
    }
    else showToast('검색한 유저가 없습니다.');
  }

  Future<void> _searchUsers(String query) async {
    try {
      inputController.text="";
      _searchResults =[];
      // SetParams 객체를 생성하여 검색 쿼리 설정
      SetParams setParams = SetParams(
        desc: TopicDescription(
          public: query, // 유저 이름을 검색 키워드로 설정
        ),
      );
      // fnd 토픽에 메타데이터 설정 요청 보내기
      var ctrl = await _fndSearchUserTopic.setMeta(setParams);

   // GetQuery 객체를 생성하여 검색 결과 요청
    GetQuery getQuery = GetQuery(
      topic : _fndSearchUserTopic.name,
      what: 'sub',
      //sub: GetOptsType(user: query), // 적절한 GetOptsType 설정
    );
    // fnd 토픽에 메타데이터 요청 보내기
    var meta = await _fndSearchUserTopic.getMeta(getQuery);
      setState(() {
      _isUserSearchLoading=false;     
    });
    if(meta?.text !=null && meta.text =="no content") {showToast('해당 유저는 친구가 아닙니다.');}

    print("");
    // if(meta?.text=="no content")
    //   showToast("해당 유저없음");
    // 메타데이터 응답 처리
    // if (meta != null && meta.sub != null) {
    //   setState(() {
    //     // _searchResults = meta.sub!.map((sub) {
    //     //   return User(
    //     //     id: sub.user ?? 'Unknown ID',
    //     //     name: sub.public?['fn'] ?? 'Unknown',
    //     //     email: sub.public?['email'] ?? 'No Email',
    //     //     picture: "",
    //     //     nickname: '',
    //     //   );
    //     // }).toList();
    //   });
    //   }
    } catch (err) {
      print("err search : $err");
      isLoading=false;
    }
  }

  void onClickSearchUser(String inputString) {
    if (inputString.isEmpty) {
      showToast("내용입력");
      return;
    }
    tinode_global.getFndTopic();
  }

    Widget _topBarUserSearchWidget()
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

  Widget _searchUserWidget()
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
                                  controller: searchUserController,
                                  onFieldSubmitted: (text) {
                                    // widget.changePage(RouteString.disvoerSearch, text);
                                  },
                                  onChanged: (text) {
                                    _isUserSearchLoading = true;
                                    if (previousUserSearchText.isEmpty &&
                                        text.isNotEmpty) {
                                      setState(() {
                                        _isUserSearchMode = true;
                                      });
                                      _searchUsers(text);
                                      isExistUserSearchText.value = true;
                                    } else if (previousUserSearchText.isNotEmpty &&
                                        text.isEmpty) {
                                      setState(() {
                                        _isUserSearchMode = false;
                                      });
                                    } else {
                                      print("검색");
                                      print(text);
                                      print(searchUserController.text);
                                      _searchUsers(text);
                                      isExistUserSearchText.value = true;
                                    }
                                    previousUserSearchText = text;
                                  },
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: FontConstants.AppFont,
                                      fontSize: 16),
                                  textInputAction: TextInputAction.search,
                                  decoration: InputDecoration(
                                    hintText: '유저 검색',
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
                              Obx(() => isExistUserSearchText.value
                                  ? GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isExistUserSearchText.value = false;
                                          searchUserController.text = "";
                                          previousUserSearchText = "";
                                          _isUserSearchMode = false;
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
                    _topBarUserSearchWidget(),
                    // Padding(
                    //     padding: EdgeInsets.only(left: 10, right: 10),
                    //     child: CustomTitleBar(callBack: (){
                    //       Get.to(ProfileScreen(user: Constants.user, tinode: tinode,));
                    //     },onTapLogo: (){
                    //       widget.onTapLogo();
                    //     },)),
                    // SizedBox(height: Get.height * 0.02),
                    _searchUserWidget(),
                    // 친구리스트 보여지는 영역
                    _isUserSearchMode
                        ? Expanded(
                            child: _isUserSearchLoading
                                ? LoadingWidget()
                                : _searchResults.isEmpty
                                    ? Center(
                                        child: AppText(
                                          text: "empty_search".tr(),
                                          fontSize: 13,
                                          color: ColorConstants.gray3,
                                        ),
                                      )
                                    : Container(
                                        padding: EdgeInsets.only(left: 10, right: 10),
                                        child: SingleChildScrollView(                                          
                                          child: Column(
                                            children: [                                           
                                              _searchResults.isNotEmpty? 
                                              Column(
                                                      children: [                                                      
                                                        ListView.builder(
                                                            shrinkWrap: true,
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            itemCount: _searchResults.length,
                                                            itemBuilder:
                                                                (context,index) {
                                                              Key key = Key(
                                                                  _searchResults[index].id.toString());
                                                              return UserListItemWidget(
                                                                key: key,
                                                                user:_searchResults[index],
                                                                isShowAction:
                                                                    true,
                                                                    unFollowUser: (){
                                                                      //_delFriend(_searchResults[index].id);
                                                                       setState(() {
                                                                    _searchResults.removeAt(index);
                                                                  });
                                                                    },
                                                                deleteUser: () {
                                                                  setState(() {
                                                                    _searchResults.removeAt(index);
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
                            child: _isUserSearchLoading
                                ? LoadingWidget()
                                : _searchResults.length == 0
                                    ? Center(
                                        child: AppText(
                                          text: "유저가 없습니다.",
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
                                             
                                              _searchResults.isNotEmpty
                                                  ? Column(
                                                      children: [                                                    
                                                        ListView.builder(
                                                            shrinkWrap: true,
                                                            physics: NeverScrollableScrollPhysics(),
                                                            itemCount: _searchResults.length,
                                                            itemBuilder: (context,index) {
                                                              Key key = Key(_searchResults[index].id.toString());
                                                              return UserListItemWidget(
                                                                key: key,
                                                                user: _searchResults[index],
                                                                isShowAction: true,
                                                                unFollowUser:(){
                                                                 // _delFriend(_searchResults[index].id);
                                                                   setState(() {
                                                                    _searchResults.removeAt(index);
                                                                  });
                                                                },
                                                                deleteUser: () {
                                                                  setState(() {
                                                                    _searchResults.removeAt(index);
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
                   // SizedBox(height: Constants.navBarHeight,),
                  ],
                ),
              ),
            )));
  }
}
