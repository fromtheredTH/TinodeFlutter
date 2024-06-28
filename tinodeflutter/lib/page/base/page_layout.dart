import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../Constants/ColorConstants.dart';
import '../../helpers/common_util.dart';


class PageLayout extends StatefulWidget {
  PageLayout(
      {Key? key,
      required this.child,
      this.onBack,
      this.onTap,
      this.isLoading,
      this.isAvoidResize,
      this.drawer,
      this.endDrawer,
      this.bgColor,
      this.safeAreaColor,
      this.floatingButton,
      this.orientation,
        this.isKeyboardHide = true,
      this.scaffoldKey})
      : super(key: key) {
    isLoading ??= false;
    isAvoidResize ??= true;
    drawer ??= null;
    endDrawer ??= null;
    bgColor ??= ColorConstants.colorBg1;
    orientation ??= Orientation.portrait;
    safeAreaColor ??= ColorConstants.colorBg1;
  }

  Widget child;
  Future<bool> Function()? onBack;
  Future<bool> Function()? onTap;
  bool? isLoading;
  bool? isAvoidResize;
  Widget? drawer;
  Widget? endDrawer;
  Widget? floatingButton;
  bool isKeyboardHide;
  Color? bgColor;
  Color? safeAreaColor;
  Orientation? orientation;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  PageLayoutState createState() => PageLayoutState();
}

class PageLayoutState extends State<PageLayout> {
  @override
  void initState() {
    WidgetsBinding.instance.renderView.automaticSystemUiAdjustment =
    false; //<--
    super.initState();
  }
    void hideKeyboard() {
    if (keyboardIsVisible(context)) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orientation == Orientation.landscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      // SystemChrome.setSystemUIOverlayStyle(
      //   SystemUiOverlayStyle(
      //       statusBarColor: ColorConstants.colorBg1,
      //       statusBarBrightness: Platform.isIOS ? Brightness.light : Brightness.dark,
      //       statusBarIconBrightness: Platform.isIOS ? Brightness.dark : Brightness.light), // Or Brightness.dark
      // );
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    return ModalProgressHUD(
      inAsyncCall: widget.isLoading ?? false,
      child: Material(
          type: MaterialType.transparency,
          child: GestureDetector(
            onTap: (){
              if(widget.isKeyboardHide)
                FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Container(
              color: widget.safeAreaColor,
              child: SafeArea(
                child: Container(
                  child: Scaffold(
                    key: widget.scaffoldKey,
                    resizeToAvoidBottomInset: widget.isAvoidResize,
                    drawer: widget.drawer,
                    endDrawer: widget.endDrawer,
                    body: Container(
                      color: widget.bgColor,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height,
                      child: GestureDetector(
                        onTap: widget.onTap ?? hideKeyboard,
                        child: Center(
                          child: widget.child,
                        ),
                      ),
                    ),
                    floatingActionButtonLocation: FloatingActionButtonLocation
                        .endFloat,
                    floatingActionButton: widget.floatingButton,
                  ),
                  // child: ,
                ),
              ),
            ),
          )
      ),
    );
  }
}
