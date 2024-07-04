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
import 'package:tinodeflutter/Screen/ProfileScreen.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/components/UserListItemWidget.dart';
import 'package:tinodeflutter/components/focus_detector.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/tinode/tinode.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../global/DioClient.dart';


class FriendListScreen extends StatefulWidget {
  FriendListScreen({ 
   Key? key,  
   required this.tinode,
  // required this.changePage, required this.onTapLogo, 
  // required this.discoverController
  });
  // Function(String, String) changePage;
  // String? hashTag;
  // Function() onTapLogo;
  // HomeController discoverController;
  Tinode tinode;
  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
  // State<FriendListScreen> createState() => _FriendListScreen(discoverController);
}

// class _FriendListScreen extends BaseState<FriendListScreen> {
class _FriendListScreenState extends State<FriendListScreen> {

  // _FriendListScreen(HomeController discoverController){
  //   discoverController.initHome = initHome;
  // }

  void initHome(){
    setState(() {
      isSearchMode = false;
      searchController.text = "";
    });
  }

  late Tinode tinode;

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

  List<User> users = <User>[];
  List<TopicSubscription> userTopicSubList = <TopicSubscription>[];


  Future<void> getSearch(String query) async {
    DioClient.searchTotal(query, 5, 0).then((response) {
      if(query == searchController.text){
        List<User> userResults = response.data["users"] == null ? [] : response
            .data["users"].map((json) => User.fromJson(json)).toList().cast<
            User>();
        // List<GameModel> gameResults = response.data["games"] == null ? [] : response
        //     .data["games"].map((json) => GameModel.fromJson(json)).toList().cast<
        //     GameModel>();
        // List<CommunityModel> communityResults = response.data["community"] == null ? [] : response
        //     .data["community"].map((json) => CommunityModel.fromJson(json)).toList().cast<
        //     CommunityModel>();
        setState(() {
          users = userResults;
          // games = gameResults;
          // communities = communityResults;
          isSearchLoading = false;
        });
      }
    });
  }

  @override
  void initState() {
   // hashTag = widget.hashTag;
    super.initState();
  //  scrollController.addListener(getNextPost);
    // if(hashTag != null){
    //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //     widget.changePage(RouteString.disvoerSearch, hashTag!);
    //   });
    // }

    // ReceivePort _port = ReceivePort();
    // IsolateNameServer.registerPortWithName(_port.sendPort, 'firbase_port_discover');
    // _port.listen((dynamic data) async {
    //   if (mounted) {
    //     await Constants.fetchChatRooms();
    //     setState(() {

    //     });
    //   }
    // });

    // event.on<ChatReceivedEvent>().listen((event) async {
    //   if (mounted) {
    //     await Constants.fetchChatRooms();
    //     setState(() {

    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = size.width * 0.4 * 1.8; // Adjust the fraction as needed
    final double itemWidth = size.width * 0.4;

    return FocusDetector(
        onFocusLost: () {

    },
    onFocusGained: () {
    setState(() {

    });
    },
    child: GestureDetector(
      onTap: FocusScope.of(context).unfocus,
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 24, 197, 160),
          resizeToAvoidBottomInset: true,
          body: Padding(
            padding:  EdgeInsets.only(right: Get.width*0.01,left: Get.width*0.01),
            child: Column(
              children: [
                 SizedBox(height: Get.height * 0.07),

                // Padding(
                //     padding: EdgeInsets.only(left: 10, right: 10),
                //     child: CustomTitleBar(callBack: (){
                //       Get.to(ProfileScreen(user: Constants.user, tinode: tinode,));
                //     },onTapLogo: (){
                //       widget.onTapLogo();
                //     },)),
                SizedBox(height: Get.height*0.02),
                Padding(
                  padding: EdgeInsets.only(
                      right: Get.width * 0.02, left: Get.width * 0.02),
                  child: Container(
                      width: Get.width, // Set width according to your needs
                      decoration: BoxDecoration(
                        color: ColorConstants.searchBackColor,
                        borderRadius:
                        BorderRadius.circular(6.0), // Adjust the value as needed
                      ),
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: TextFormField(
                              controller: searchController,
                              onFieldSubmitted: (text){
                                // widget.changePage(RouteString.disvoerSearch, text);
                              },
                              onChanged: (text){

                                isSearchLoading = true;
                                if(previousSearchText.isEmpty && text.isNotEmpty){
                                  setState(() {
                                    isSearchMode = true;
                                  });
                                  getSearch(text);
                                  isExistSearchText.value = true;
                                }else if(previousSearchText.isNotEmpty && text.isEmpty){
                                  setState(() {
                                    isSearchMode = false;
                                  });
                                }else{
                                  print("검색");
                                  print(text);
                                  print(searchController.text);
                                  getSearch(text);
                                  isExistSearchText.value = true;
                                }
                                previousSearchText = text;
                              },
                              style: TextStyle(
                                  color: ColorConstants.white,
                                  fontFamily: FontConstants.AppFont,
                                  fontSize: 16
                              ),
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                hintText: '친구 검색',
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 12.0), // Adjust vertical padding
                                border: InputBorder.none,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SvgPicture.asset(ImageConstants.searchIcon,
                                    color: Colors.white,
                                  ),
                                ),
                                // Align hintText to center
                                hintStyle: TextStyle(
                                    color: ColorConstants.halfWhite,
                                    fontFamily: FontConstants.AppFont,
                                    fontSize: 16),
                                // alignLabelWithHint: true,
                              ),
                            ),
                          ),

                          Obx(() => isExistSearchText.value ?
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                isExistSearchText.value = false;
                                searchController.text = "";
                                previousSearchText = "";
                                isSearchMode = false;
                              });
                            },
                            child: ImageUtils.setImage(ImageConstants.searchX, 20, 20),
                          ) : Container()
                          ),

                          SizedBox(width: 10,)
                        ],
                      )
                  ),
                ),
                isSearchMode ?
                Expanded(
                    child: isSearchLoading ?
                   // LoadingWidget()
                   //     : users.length == 0 ?
                    Center(
                      child: AppText(
                        text: "empty_search".tr(),
                        fontSize: 13,
                        color: ColorConstants.gray3,
                      ),
                    )
                        : Padding(
                      padding: EdgeInsets.only(left: 10,right: 10),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 25,),

                            users.isNotEmpty ?
                            Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(bottom: 25),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(width: 30),
                                      Expanded(child: Container(height: 0.5, color: ColorConstants.colorMain)),
                                      SizedBox(width: 20),
                                      AppText(
                                        text: "user".tr(),
                                        fontSize: 10,
                                        color: ColorConstants.colorMain,
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(child: Container(height:0.51, color: ColorConstants.colorMain)),
                                      SizedBox(width: 30),
                                    ],
                                  ),
                                ),

                                ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: users.length,
                                    itemBuilder: (context, index) {
                                      Key key = Key(users[index].id.toString());
                                      return UserListItemWidget(key: key, userTopicSub: userTopicSubList[index], isShowAction: true, deleteUser: (){
                                        setState(() {
                                          users.removeAt(index);
                                        });
                                      },);
                                    }
                                ),
                              ],
                            ) : Container(),

                            // games.isNotEmpty ?
                            // Column(
                            //   children: [
                            //     Container(
                            //       padding: EdgeInsets.only(bottom: 25),
                            //       child: Row(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         crossAxisAlignment: CrossAxisAlignment.center,
                            //         children: [
                            //           SizedBox(width: 30),
                            //           Expanded(child: Container(height: 0.5, color: ColorConstants.colorMain)),
                            //           SizedBox(width: 20),
                            //           AppText(
                            //             text: "game".tr(),
                            //             fontSize: 10,
                            //             color: ColorConstants.colorMain,
                            //           ),
                            //           SizedBox(width: 20),
                            //           Expanded(child: Container(height:0.51, color: ColorConstants.colorMain)),
                            //           SizedBox(width: 30),
                            //         ],
                            //       ),
                            //     ),

                            //     ListView.builder(
                            //         shrinkWrap: true,
                            //         physics: NeverScrollableScrollPhysics(),
                            //         itemCount: games.length,
                            //         itemBuilder: (context, index) {
                            //           return GameSimpleItemWidget(game: games[index]);
                            //         }
                            //     ),
                            //   ],
                            // ) : Container(),

                            // communities.isNotEmpty ?
                            // Column(
                            //   children: [
                            //     Container(
                            //       padding: EdgeInsets.only(bottom: 25),
                            //       child: Row(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         crossAxisAlignment: CrossAxisAlignment.center,
                            //         children: [
                            //           SizedBox(width: 30),
                            //           Expanded(child: Container(height: 0.5, color: ColorConstants.colorMain)),
                            //           SizedBox(width: 20),
                            //           AppText(
                            //             text: "community".tr(),
                            //             fontSize: 10,
                            //             color: ColorConstants.colorMain,
                            //           ),
                            //           SizedBox(width: 20),
                            //           Expanded(child: Container(height:0.51, color: ColorConstants.colorMain)),
                            //           SizedBox(width: 30),
                            //         ],
                            //       ),
                            //     ),

                            //     ListView.builder(
                            //         shrinkWrap: true,
                            //         physics: NeverScrollableScrollPhysics(),
                            //         itemCount: communities.length,
                            //         itemBuilder: (context, index) {
                            //           return CommunitySimpleItemWidget(community: communities[index]);
                            //         }
                            //     ),
                            //   ],
                            // ) : Container()
                          ],
                        ),
                      ),
                    )
                )
                    : Expanded(
                      child: Container()
                    // child: FutureBuilder(
                    //     future: postFuture,
                    //     builder: (context, snapshot) {
                    //       if(snapshot.hasData){
                    //         return RefreshIndicator(
                    //             color: ColorConstants.colorMain,
                    //             onRefresh: () async {
                    //           //    await refreshPosts();
                    //               setState(() {
                    //               });
                    //             },
                    //             child: GridView.builder(
                    //               padding: EdgeInsets.only(top: 15),
                    //               shrinkWrap: true,
                    //               scrollDirection: Axis.vertical,
                    //               controller: scrollController,
                    //               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //                   crossAxisCount: 2, // 1개의 행에 항목을 3개씩
                    //                   mainAxisSpacing: 10,
                    //                   crossAxisSpacing: 10,
                    //                   childAspectRatio: (itemWidth / itemHeight)
                    //               ),
                    //               itemCount: hasPostNextPage ? posts.length+1 : posts.length,
                    //               itemBuilder: (context, index) {
                    //                 if(posts.length == index){
                    //                   return Padding(
                    //                     padding: EdgeInsets.only(top: 30, bottom: 50),
                    //                     child: LoadingWidget(),
                    //                   );
                    //                 }
                    //                 return DiscoverWidget(post: posts[index]);
                    //               },
                    //             )
                    //         );
                    //       }
                    //       return Expanded(
                    //           child: LoadingWidget()
                    //       );
                    //     }
                    // )
                ),
               // SizedBox(height: Get.height*0.05,)

              ],
            ),
          ),
        )
    )
    );
  }
}
