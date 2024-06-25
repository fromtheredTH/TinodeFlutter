import 'package:flutter/material.dart';

class FadeTransRoute<T> extends MaterialPageRoute<T> {
  FadeTransRoute({required WidgetBuilder builder, RouteSettings? settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
//    if (settings.isInitialRoute) return child;

    return FadeTransition(opacity: animation, child: child);
  }
}

class SlideRightTransRoute<T> extends MaterialPageRoute<T> {
  SlideRightTransRoute({required WidgetBuilder builder, RouteSettings? settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
//    if (settings.isInitialRoute) return child;

    return SlideTransition(
        position: Tween<Offset>(begin: Offset(1,0), end: Offset.zero)
            .animate(animation),
        child: child);
  }
}

class SlideBottomTransRoute<T> extends MaterialPageRoute<T> {
  SlideBottomTransRoute({required WidgetBuilder builder, RouteSettings? settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {

    return SlideTransition(
        position: Tween<Offset>(begin: Offset(0, 1), end: Offset.zero)
            .animate(animation),
        child: child);
  }
}
