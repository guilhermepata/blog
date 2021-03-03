import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: AppShell(),
    );
  }
}

// class ControllerHolder extends ValueNotifier {
//   ControllerHolder._privateConstructor(value) : super(value);

//   static final ControllerHolder _instance =
//       ControllerHolder._privateConstructor(ScrollController());

//   factory ControllerHolder() {
//     return _instance;
//   }

//   static ScrollController get controller {
//     return ControllerHolder().value;
//   }

//   static set controller(ScrollController value) {
//     ControllerHolder().value = value;
//   }
// }

/// A "shell" with the app bar and drawer
class AppShell extends StatefulWidget {
  AppShell({Key key}) : super(key: key);

  @override
  _AppShellState createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selectedMenu = 0;
  bool isAppBarRed = false;
  ScrollController scrollController = ScrollController();

  // scrollController controls appbar elevation
  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels > 0)
        setState(() {
          isAppBarRed = true;
        });
      else
        setState(() {
          isAppBarRed = false;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('App bar'),
          backgroundColor: isAppBarRed ? Colors.red : Colors.black54),
      body: Center(
        child: AnimatedCrossFade(
          duration: Duration(milliseconds: 1000),
          firstChild: selectedMenu == 0
              ? FirstScreen(
                  scrollController: scrollController,
                )
              : Container(),
          secondChild: selectedMenu == 1
              ? SecondScreen(
                  scrollController: scrollController,
                )
              : Container(),
          crossFadeState: selectedMenu == 0
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            ListTile(
              selected: selectedMenu == 0,
              title: Text('First screen'),
              onTap: () => setState(() {
                selectedMenu = 0;
                isAppBarRed = false;
                Navigator.of(context).pop();
              }),
            ),
            ListTile(
              selected: selectedMenu == 1,
              title: Text('Second screen'),
              onTap: () => setState(() {
                selectedMenu = 1;
                isAppBarRed = false;
                Navigator.of(context).pop();
              }),
            )
          ],
        ),
      ),
    );
  }
}

class FirstScreen extends StatelessWidget {
  final ScrollController scrollController;

  const FirstScreen({Key key, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 300,
      child: ListView.builder(
        controller: scrollController,
        itemBuilder: (_, __) {
          return ListTile(
            title: Text('First screen list item'),
          );
        },
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  final ScrollController scrollController;

  const SecondScreen({Key key, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 300,
      child: ListView.builder(
        itemCount: 100,
        controller: scrollController,
        itemBuilder: (_, __) {
          return ListTile(
            title: Text('Second screen list item'),
          );
        },
      ),
    );
  }
}
