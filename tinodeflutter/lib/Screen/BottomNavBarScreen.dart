import 'dart:async';


import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:tinodeflutter/Screen/FriendListScreen.dart';
import 'package:tinodeflutter/Screen/ProfileScreen.dart';
import 'package:tinodeflutter/Screen/messageRoomListScreen.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/page/base/base_state.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/Constants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/RouteString.dart';
import '../../../Constants/utils.dart';
import '../../../global/DioClient.dart';

class InitController{
  late void Function() initHome;
}

class BottomNavBarScreen extends StatefulWidget {
  BottomNavBarScreen({super.key, this.tagString});
  String? tagString;

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreen();
}

class _BottomNavBarScreen extends BaseState<BottomNavBarScreen> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

  final InitController messageListScreenInitController = InitController();
  final InitController friendScreenInitController = InitController();

   final GlobalKey<NavigatorState> _discoverNavigatorKey = GlobalKey<NavigatorState>();
   final GlobalKey _globalKey = GlobalKey();
   PersistentTabController controller = PersistentTabController();

  ProfileScreen profileScreen = ProfileScreen(user: Constants.user,);
  late MessageRoomListScreen messageRoomListScreen;
  late FriendListScreen friendListScreen;
      // ChatPage chatPage = ChatPage();

   String? hashTag;
   int previousIndex = 0;

   List<Widget> _buildScreens() {
     return [
      messageRoomListScreen,
      friendListScreen,
      profileScreen,
       // chatPage,
      // profileScreen,
      // //  communityScreen,
       // ZemTownScreen(),
       //notificationScreen
     ];
   }

   void homeInit(){

   }

   void discoverInit(){

   }

  //  void communityInit(){

  //  }

   List<PersistentBottomNavBarItem> _navBarsItems() {
     return [
       PersistentBottomNavBarItem(
           icon: Image.asset(ImageConstants.chatIcon, color: ColorConstants.colorMain, height: Constants.navBarIconSize, width: Constants.navBarIconSize),
           title: "채팅",
           activeColorPrimary: ColorConstants.colorMain,
           inactiveColorPrimary: ColorConstants.bottomGrey,
           //activeColorSecondary:  ColorConstants.colorMain,
           inactiveIcon: Image.asset(ImageConstants.chatIcon, color: ColorConstants.bottomGrey, height: Constants.navBarIconSize, width: Constants.navBarIconSize)
       ),
       PersistentBottomNavBarItem(
          icon: Image.asset(ImageConstants.bottomCommunity, color: ColorConstants.colorMain, height: Constants.navBarIconSize, width: Constants.navBarIconSize),
          title: "친구",
           activeColorPrimary: ColorConstants.colorMain,
           inactiveColorPrimary: ColorConstants.bottomGrey,
           inactiveIcon: Image.asset(ImageConstants.bottomCommunity, color: ColorConstants.bottomGrey, height: Constants.navBarIconSize, width: Constants.navBarIconSize)
       ),
       PersistentBottomNavBarItem(
          icon: Image.asset(ImageConstants.profileIcon, color: ColorConstants.colorMain, height: Constants.navBarIconSize, width: Constants.navBarIconSize),
          title: "나",
           activeColorPrimary: ColorConstants.colorMain,
           inactiveColorPrimary: ColorConstants.bottomGrey,
           inactiveIcon: Image.asset(ImageConstants.profileIcon, color: ColorConstants.bottomGrey, height: Constants.navBarIconSize, width: Constants.navBarIconSize)
       ),

      //  PersistentBottomNavBarItem(
      //      icon: Image.asset(ImageConstants.bottomCommunity, color: ColorConstants.colorMain, height: Constants.navBarIconSize, width: Constants.navBarIconSize),
      //      title: "Community",
      //      activeColorPrimary: ColorConstants.colorMain,
      //      inactiveColorPrimary: ColorConstants.bottomGrey,
      //      inactiveIcon: Image.asset(ImageConstants.bottomCommunityUnselect,color: ColorConstants.bottomGrey, height: Constants.navBarIconSize, width: Constants.navBarIconSize)
      //  ),
      //  // PersistentBottomNavBarItem(
      //  //   icon: SvgPicture.asset(ImageConstants.zemtownIcon, color: ColorConstants.colorMain, height: Constants.navBarIconSize, width: Constants.navBarIconSize),
      //  //     //SvgPicture.asset(ImageString.educationIcon),
      //  //     title: "Zemtown",
      //  //     activeColorPrimary: ColorConstants.colorMain,
      //  //     inactiveColorPrimary: ColorConstants.bottomGrey,
      //  //     inactiveIcon: SvgPicture.asset(ImageConstants.zemtownIcon,color: ColorConstants.bottomGrey, height: Constants.navBarIconSize, width: Constants.navBarIconSize)
      //  // ),
      //  PersistentBottomNavBarItem(
      //      icon: Image.asset(ImageConstants.bottomNotification, color: ColorConstants.colorMain, height: Constants.navBarIconSize, width: Constants.navBarIconSize),
      //      title: "Notification",
      //      activeColorPrimary: ColorConstants.colorMain,
      //      inactiveColorPrimary: ColorConstants.bottomGrey,
      //      inactiveIcon: Image.asset(ImageConstants.bottomNotificationUnselect, color: ColorConstants.bottomGrey)
      //  ),
     ];
   }

  //  MaterialPageRoute onDiscoverGenerateRoute(RouteSettings settings) {
  //    if(settings.name == RouteString.disvoerMain) {
  //      return MaterialPageRoute<dynamic> (
  //          builder: (context) => discoverScreen, settings: settings);
  //    }else if(settings.name == RouteString.disvoerSearch) {
  //      return MaterialPageRoute<dynamic> (
  //          builder: (context) => DiscoverSearchScreen(searchStr: settings.arguments as String), settings: settings);
  //    }
  //    throw Exception("Unknown route : ${settings.name}");
  //  }

   @override
  void initState() {
     //hashTag = widget.tagString;
    //  
    //homeScreen = HomeScreen(homeController: homeController,);
     messageRoomListScreen = MessageRoomListScreen(messageListScreenInitController: messageListScreenInitController,);
     friendListScreen = FriendListScreen(friendScreenInitController: friendScreenInitController,);
    // discoverScreen = DiscoverScreen(discoverController: discoverController, hashTag: hashTag, changePage: (route, searchStr){
    //    _discoverNavigatorKey.currentState?.pushNamed(
    //        route, arguments: searchStr
    //    );
    //  }, onTapLogo: (){
    //   controller.jumpToTab(0);
    // },);
    
    // communityScreen = CommunityScreen(communityController: communityController, onTapLogo: (){
    //   controller.jumpToTab(0);
    // },);
    // notificationScreen = NotificationScreen(onTapLogo: (){
    //   controller.jumpToTab(0);
    // },);
    super.initState();
    if(widget.tagString != null){
      controller.jumpToTab(1);
      previousIndex = 1;
    }

     
     final _appLinks = AppLinks();

     _appLinks.allUriLinkStream.listen((uri) async {
       String? path;
       String id = "";
       for(int i=0;i<uri.pathSegments.length;i++) {
         if (i == 0) {
           path = uri.pathSegments[i];
         } else if (i == 1) {
           id = uri.pathSegments[i];
         }
       }


       if(path != null && (await FirebaseAuth.instance.currentUser) != null) {
         if (path == "feed") {
           Utils.showDialogWidget(context);
           var response = await DioClient.getPost(id);
           String? commentId = uri.queryParameters["commentId"];
           Get.back();
          //  Get.to(PostDetailScreen(post: PostModel.fromJson(response.data), commentId: commentId,));
         }
        //   else if (path == "game") {
        //    Utils.showDialogWidget(context);
        //    var response = await DioClient.getGameDetail(id);
        //    GameModel result = GameModel.fromJson(response.data["result"]["game"]);
        //    Get.back();
        //    Get.to(DiscoverGameDetails(game: result, refreshGame: (game){},));
        //  }
          else { // 패스는 유저 닉네임
           Utils.showDialogWidget(context);
           var response = await DioClient.getUser(path);
           UserModel user = UserModel.fromJson(response.data["result"]["target"]);
           Get.back();
           if(user.id != 0) {
             Get.to(ProfileScreen(user: user));
           }
         }
       }
     });



  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
        child: Scaffold(
          key: _globalKey,
          bottomNavigationBar:
          PersistentTabView(
            context,
            screens: _buildScreens(),
            items: _navBarsItems(),
            confineInSafeArea: true,
            bottomScreenMargin: 0,
            controller: controller,
            backgroundColor: Colors.grey.shade200,
            resizeToAvoidBottomInset: true,
            stateManagement: true,
            navBarHeight: Constants.navBarHeight,
            onItemSelected: (index){
              print(controller.index);
              if(previousIndex == index){
                if(index == 0){
                  messageListScreenInitController.initHome();
                }else if(index == 1){
                  friendScreenInitController.initHome();
                  // if(_discoverNavigatorKey.currentState?.canPop() ?? false){
                  //   _discoverNavigatorKey.currentState!.pop();
                  // }
                }
                else if(index == 2){
                  // communityController.initHome();
                }
              }
              previousIndex = index;
            },
            hideNavigationBarWhenKeyboardShows: true,
            decoration: NavBarDecoration(
              colorBehindNavBar: Colors.transparent,
            ),
            popAllScreensOnTapOfSelectedTab: true,
            popAllScreensOnTapAnyTabs: true,
            popActionScreens: PopActionScreensType.all,
            itemAnimationProperties: ItemAnimationProperties(
              duration: Duration(milliseconds: 200),
              curve: Curves.ease,
            ),
            screenTransitionAnimation: ScreenTransitionAnimation(
              animateTabTransition: true,
              curve: Curves.ease,
              duration: Duration(milliseconds: 200),
            ),
            navBarStyle: NavBarStyle.style8,
          ),
        )
    );
  }
}
