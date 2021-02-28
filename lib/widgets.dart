import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MousePresence extends ValueNotifier {
  MousePresence._privateConstructor(value) : super(value);

  static final MousePresence _instance =
      MousePresence._privateConstructor(false);

  factory MousePresence() {
    return _instance;
  }
}

class SmoothScroller extends StatefulWidget {
  final ScrollController controller;
  final Widget child;

  const SmoothScroller({
    Key key,
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
  final double _increaseSpeedFactor = 1.2;
  double increaseSpeedFactor = 1;

  double scroll = 0;
  double delta = 0;
  bool locked = false;
  // bool triedWhenLocked = false;
  bool isScrollWheel = false;

  Future<bool> hasAnimated;

  void onPointerSignal(PointerSignalEvent pointerSignal) {
    if (pointerSignal is PointerScrollEvent) {
      if (locked) {
        hasAnimated
            .then((value) => animate(pointerSignal, wasScheduled: true))
            .then((value) {
          if (isScrollWheel) locked = false;
        });
      } else {
        animate(pointerSignal);
        // locked = true;
      }
    }
  }

  void animate(PointerScrollEvent pointerSignal, {bool wasScheduled = false}) {
    locked = true;
    scroll = widget.controller.position.pixels;
    int micros;
    double dy;

    dy = pointerSignal.scrollDelta.dy;
    isScrollWheel = dy.abs() % 100 == 0;
    if (isScrollWheel)
      delta = dy * scrollWheelExtentFactor;
    else
      delta = dy * touchPadExtentFactor;

    // if (triedWhenLocked) {
    //   if (isScrollWheel) {
    //     increaseSpeedFactor = increaseSpeedFactor * _increaseSpeedFactor;
    //     delta = delta * increaseSpeedFactor;
    //   }
    //   triedWhenLocked = false;
    // } else {
    //   increaseSpeedFactor = 1;
    // }

    // print('Speed factor is $increaseSpeedFactor');

    scroll = scroll + delta;
    if (scroll > widget.controller.position.maxScrollExtent) {
      delta = delta - (scroll - widget.controller.position.maxScrollExtent);
      scroll = widget.controller.position.maxScrollExtent;
    } else if (scroll < 0) {
      delta = delta + scroll;
      scroll = 0;
    }
    var scrollSpeed = isScrollWheel ? scrollWheelSpeed : touchPadSpeed;

    if (wasScheduled) {
      if (isScrollWheel) {
        increaseSpeedFactor = increaseSpeedFactor * _increaseSpeedFactor;
        scrollSpeed = scrollSpeed * increaseSpeedFactor;
      }
    } else {
      increaseSpeedFactor = 1;
    }

    micros = (delta.abs() * 1000 / (scrollSpeed / 1000)).round();
    locked = true;

    hasAnimated = widget.controller
        .animateTo(
      scroll,
      duration: Duration(microseconds: micros + 1),
      curve: isScrollWheel && !wasScheduled ? Curves.ease : Curves.linear,
      // curve: SpeedCurve(speed: animationSpeed),
    )
        .then((value) {
      // if (isScrollWheel) locked = false;
      // locked = false;
      return true;
    });

    // if (triedWhenLocked) triedWhenLocked = false;
  }

  @override
  Widget build(BuildContext context) {
    return MousePresence().value
        ? Listener(
            onPointerSignal: onPointerSignal,
            child: widget.child,
          )
        : MouseRegion(
            onHover: (_) => MousePresence().value = true,
          );
  }
}
