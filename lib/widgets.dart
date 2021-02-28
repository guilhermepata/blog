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
  final double scrollSpeed = 1;
  final double scrollExtent = 2;
  double scroll = 0;
  double delta = 0;
  bool locked = false;

  void onPointerSignal(PointerSignalEvent pointerSignal) {
    scroll = widget.controller.position.pixels;

    int micros;

    if (pointerSignal is PointerScrollEvent && !locked) {
      delta = pointerSignal.scrollDelta.dy * scrollExtent;
      scroll = scroll + delta;
      if (scroll > widget.controller.position.maxScrollExtent) {
        delta = delta - (scroll - widget.controller.position.maxScrollExtent);
        scroll = widget.controller.position.maxScrollExtent;
      } else if (scroll < 0) {
        delta = delta + scroll;
        scroll = 0;
      }
      micros = (delta.abs() * 1000 / scrollSpeed).round();
      locked = true;
      widget.controller
          .animateTo(
            scroll,
            duration: Duration(microseconds: micros + 1),
            curve: Curves.linear,
          )
          .whenComplete(() => locked = false);
    }
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
