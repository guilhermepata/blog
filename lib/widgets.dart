import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;

class MouseState extends ValueNotifier {
  MouseState._privateConstructor(value) : super(value);

  // bool get isPresent => value;
  // set isPresent(bool newValue) {
  //   this.value = newValue;
  // }

  static final MouseState _instance = MouseState._privateConstructor(false);

  factory MouseState() {
    return _instance;
  }

  static bool get isPresent {
    return MouseState().value;
  }

  static set isPresent(bool value) {
    MouseState().value = value;
  }
}

class SmoothScroller extends StatefulWidget {
  final ScrollController? controller;
  final Widget? child;

  const SmoothScroller({
    Key? key,
    this.controller,
    this.child,
  }) : super(key: key);

  @override
  _SmoothScrollerState createState() => _SmoothScrollerState();
}

class _SmoothScrollerState extends State<SmoothScroller> {
  // final int animationLength = 250;
  final double touchPadSpeed = 8100; // in logical pixels per second
  final double touchPadExtentFactor = .9;

  final double scrollWheelSpeed = 710;
  final double scrollWheelExtentFactor = 1.5;
  final double _increaseSpeedFactor = 3;
  double increaseSpeedFactor = 1;

  double scrollPosition = 0;
  double delta = 0;
  bool locked = false;
  // bool triedWhenLocked = false;
  bool isScrollWheel = false;

  late Future<bool> hasAnimated;

  bool hasTriedToDetect = false;

  bool hasNewSchedule = false;

  void onPointerSignal(PointerSignalEvent pointerSignal) {
    if (hasTriedToDetect && !MouseState.isPresent) return;

    if (!hasTriedToDetect) {
      hasTriedToDetect = true;
      if (pointerSignal.kind == PointerDeviceKind.mouse)
        MouseState.isPresent = true;
      else
        MouseState.isPresent = false;
    }

    if (pointerSignal is PointerScrollEvent) {
      if (locked) {
        hasNewSchedule = true;
        hasAnimated.then((value) {
          animate(pointerSignal, wasScheduled: true);
          hasAnimated.then((value) {
            if (!hasNewSchedule) locked = false;
          });
        });
      } else {
        animate(pointerSignal);
      }
    }
  }

  void animate(PointerScrollEvent pointerSignal, {bool wasScheduled = false}) {
    hasNewSchedule = false;
    // locked = true;
    scrollPosition = widget.controller!.position.pixels;
    int micros;
    double dy;

    // print('Running scheduled: $wasScheduled');

    dy = pointerSignal.scrollDelta.dy;
    isScrollWheel = dy.abs() % 100 == 0;
    if (isScrollWheel)
      delta = dy * scrollWheelExtentFactor;
    else
      delta = dy * touchPadExtentFactor;

    scrollPosition = scrollPosition + delta;
    if (scrollPosition > widget.controller!.position.maxScrollExtent) {
      delta =
          delta - (scrollPosition - widget.controller!.position.maxScrollExtent);
      scrollPosition = widget.controller!.position.maxScrollExtent;
    } else if (scrollPosition < 0) {
      delta = delta + scrollPosition;
      scrollPosition = 0;
    }
    var scrollSpeed = isScrollWheel ? scrollWheelSpeed : touchPadSpeed;

    if (wasScheduled) {
      if (isScrollWheel) {
        increaseSpeedFactor = increaseSpeedFactor * _increaseSpeedFactor;
        scrollPosition += delta * (increaseSpeedFactor - 1);
        scrollSpeed = scrollSpeed * increaseSpeedFactor;
        // locked = true;
      }
    } else {
      increaseSpeedFactor = 1;
    }

    micros = (delta.abs() * 1000 / (scrollSpeed / 1000)).round();
    // locked = true;
    if (isScrollWheel)
      this.hasAnimated = widget.controller!
          .animateTo(
            scrollPosition,
            duration: Duration(microseconds: micros + 1),
            curve: isScrollWheel && !wasScheduled ? Curves.ease : Curves.linear,
          )
          .then((value) => true);
    else
      this.hasAnimated = Future(() {
        widget.controller!.jumpTo(scrollPosition);
        return true;
      });
  }

  @override
  Widget build(BuildContext context) {
    return (MouseState.isPresent || !hasTriedToDetect)
        ? Listener(
            onPointerSignal: onPointerSignal,
            child: widget.child,
          )
        : widget.child!;
  }
}
