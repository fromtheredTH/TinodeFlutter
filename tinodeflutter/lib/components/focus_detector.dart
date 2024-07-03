import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

//Focus detector
/// if story video focused then autoplay
/// else stop video
class FocusDetector extends StatefulWidget {
  const FocusDetector({
    required this.child,
    this.onFocusGained,
    this.onFocusLost,
    this.onVisibilityGained,
    this.onVisibilityLost,
    this.onForegroundGained,
    this.onForegroundLost,
    this.isWidgetTest,
    super.key,
  });

  final VoidCallback? onFocusGained;

  final VoidCallback? onFocusLost;

  final VoidCallback? onVisibilityGained;

  final VoidCallback? onVisibilityLost;

  final VoidCallback? onForegroundGained;

  final VoidCallback? onForegroundLost;

  final Widget child;

  final bool? isWidgetTest;

  @override
  FocusDetectorState createState() => FocusDetectorState();
}

class FocusDetectorState extends State<FocusDetector> with WidgetsBindingObserver {
  final _visibilityDetectorKey = UniqueKey();

  bool _isWidgetVisible = false;
  bool _isWidgetFocus = false;

  bool _isAppInForeground = true;

  @override
  void initState() {
    if (widget.isWidgetTest == true) {
      VisibilityDetectorController.instance.updateInterval = Duration.zero;
    }

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _notifyPlaneTransition(state);
  }

  void _notifyPlaneTransition(AppLifecycleState state) {
    if (!_isWidgetVisible) {
      return;
    }

    final isAppResumed = state == AppLifecycleState.resumed;
    final wasResumed = _isAppInForeground;
    if (isAppResumed && !wasResumed) {
      _isAppInForeground = true;
      _notifyFocusGain();
      _notifyForegroundGain();
      return;
    }

    final isAppPaused = state == AppLifecycleState.paused;
    if (isAppPaused && wasResumed) {
      _isAppInForeground = false;
      _notifyFocusLoss();
      _notifyForegroundLoss();
    }
  }

  @override
  Widget build(BuildContext context) => VisibilityDetector(
        key: _visibilityDetectorKey,
        onVisibilityChanged: (visibilityInfo) {
          final visibleFraction = visibilityInfo.visibleFraction;
          _notifyVisibilityStatusChange(visibleFraction);
        },
        child: widget.child,
      );

  void _notifyVisibilityStatusChange(double newVisibleFraction) {
    if (!_isAppInForeground) {
      return;
    }

    final wasFullyVisible = _isWidgetVisible;
    final isFullyVisible = newVisibleFraction == 1;
    if (!wasFullyVisible && isFullyVisible) {
      _isWidgetVisible = true;
      // _notifyFocusGain();
      _notifyVisibilityGain();
    }

    final wasFullyFocus = _isWidgetFocus;
    final isFullyFocus = newVisibleFraction >= 0.5;
    if (!wasFullyFocus && isFullyFocus) {
      _isWidgetFocus = true;
      _notifyFocusGain();
      // _notifyVisibilityGain();
    }

    final isFullyInvisible = newVisibleFraction == 0;
    if (wasFullyVisible && isFullyInvisible) {
      _isWidgetVisible = false;
      // _notifyFocusLoss();
      _notifyVisibilityLoss();
    }

    final isFullyFocusable = newVisibleFraction < 0.5;
    if (wasFullyFocus && isFullyFocusable) {
      _isWidgetFocus = false;
      _notifyFocusLoss();
      // _notifyVisibilityLoss();
    }
  }

  void _notifyFocusGain() {
    final onFocusGained = widget.onFocusGained;
    if (onFocusGained != null) {
      onFocusGained();
    }
  }

  void _notifyFocusLoss() {
    final onFocusLost = widget.onFocusLost;
    if (onFocusLost != null) {
      onFocusLost();
    }
  }

  void _notifyVisibilityGain() {
    final onVisibilityGained = widget.onVisibilityGained;
    if (onVisibilityGained != null) {
      onVisibilityGained();
    }
  }

  void _notifyVisibilityLoss() {
    final onVisibilityLost = widget.onVisibilityLost;
    if (onVisibilityLost != null) {
      onVisibilityLost();
    }
  }

  void _notifyForegroundGain() {
    final onForegroundGained = widget.onForegroundGained;
    if (onForegroundGained != null) {
      onForegroundGained();
    }
  }

  void _notifyForegroundLoss() {
    final onForegroundLost = widget.onForegroundLost;
    if (onForegroundLost != null) {
      onForegroundLost();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
