

import 'package:flutter/cupertino.dart';

class PositionRetainedScrollPhysics extends ScrollPhysics {
  static bool shouldRetain = false;
  PositionRetainedScrollPhysics({super.parent});

  @override
  PositionRetainedScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PositionRetainedScrollPhysics(
      parent: buildParent(ancestor),
    );
  }

  @override
  double adjustPositionForNewDimensions({
    required ScrollMetrics oldPosition,
    required ScrollMetrics newPosition,
    required bool isScrolling,
    required double velocity,
  }) {
    final position = super.adjustPositionForNewDimensions(
      oldPosition: oldPosition,
      newPosition: newPosition,
      isScrolling: isScrolling,
      velocity: velocity,
    );

    final diff = newPosition.maxScrollExtent - oldPosition.maxScrollExtent;
    print("값 체크 ${shouldRetain}, ${isScrolling}");

    if (shouldRetain && !isScrolling) {
      shouldRetain = false;
      return position + diff;
    } else {
      return position;
    }
  }
}