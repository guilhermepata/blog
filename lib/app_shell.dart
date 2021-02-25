import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'home_page.dart';
import 'classes.dart';

class ShellState extends ChangeNotifier {
  final BuildContext context;

  bool _isMobileLayout = false;
  double _margins = 0;
  double _gutters = 24;
  double _cardCornerRadius = 8;
  DrawerState _standardDrawerState = DrawerState.closed;
  List<Article> articles = <Article>[];
  ScrollController scrollController = ScrollController();

  ShellState(this.context) {
    context.read<AppState>().areArticlesLoaded.then((value) {
      for (var article in context.read<AppState>().articles.values)
        articles.add(article);
      notifyListeners();
    });
  }

  bool get isMobileLayout => _isMobileLayout;
  double get margins => _margins;
  double get gutters => _gutters;
  double get cardCornerRadius => _cardCornerRadius;
  DrawerState get standardDrawerState => _standardDrawerState;

  bool get displayMobileLayout {
    return (isMobileLayout ?? false) &&
        (standardDrawerState == DrawerState.closed ?? false);
  }

  set isMobileLayout(bool value) {
    _isMobileLayout = value;
    notifyListeners();
  }

  set margins(double value) {
    _margins = value;
    notifyListeners();
  }

  set gutters(double value) {
    _gutters = value;
    notifyListeners();
  }

  set cardCornerRadius(double value) {
    _cardCornerRadius = value;
    notifyListeners();
  }

  set standardDrawerState(DrawerState value) {
    _standardDrawerState = value;
    notifyListeners();
  }
}

class AppShell extends StatefulWidget {
  final void Function(AppMenu) handleMenuTapped;

  AppShell(this.handleMenuTapped);

  @override
  _AppShellState createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  bool _isMobileLayout;
  double _margins;
  double _gutters;
  double _cardCornerRadius;
  DrawerState _standardDrawerState;
  // List<Article> articles = <Article>[];
  ScrollController scrollController = ScrollController();

  bool get isMobileLayout => _isMobileLayout;
  double get margins => _margins;
  double get gutters => _gutters;
  double get cardCornerRadius => _cardCornerRadius;
  DrawerState get standardDrawerState => _standardDrawerState;

  set isMobileLayout(bool value) {
    _isMobileLayout = value;
    // context.read<ShellState>().isMobileLayout = value;
  }

  set margins(double value) {
    _margins = value;
    // context.read<ShellState>().margins = value;
  }

  set gutters(double value) {
    _gutters = value;
    // context.read<ShellState>().gutters = value;
  }

  set cardCornerRadius(double value) {
    _cardCornerRadius = value;
    // context.read<ShellState>().cardCornerRadius = value;
  }

  set standardDrawerState(DrawerState value) {
    _standardDrawerState = value;
    // context.read<ShellState>().standardDrawerState = value;
  }

  // rigth now these don't need to notify the listeners, I think
  double width, height, usefulWidth, usefulHeight;
  double appBarMargins;
  double maxContentWidth = 600;
  double contentWidth;
  double webLayoutMinWidth;
  double standardDrawerMaxWidth = 144;

  bool isInitialized = false;
  bool isAppBarElevated = false;
  //
  bool get displayMobileLayout {
    return isMobileLayout && standardDrawerState == DrawerState.closed;
  }

  // Animations
  AnimationController standardDrawerController;
  Animation<double> standardDrawerWidth;
  Animation<double> appBarSpacing;

  //for the delegate
  InnerRouterDelegate _routerDelegate = InnerRouterDelegate();
  ChildBackButtonDispatcher _backButtonDispatcher;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Defer back button dispatching to the child router
    _backButtonDispatcher = Router.of(context)
        .backButtonDispatcher
        .createChildBackButtonDispatcher();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // not sure this works
    context.read<ShellState>().scrollController = scrollController;

    standardDrawerController = AnimationController(
        value: 1.0, vsync: this, duration: Duration(milliseconds: 500));
    standardDrawerController.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.completed:
          standardDrawerState = DrawerState.open;
          break;
        case AnimationStatus.dismissed:
          standardDrawerState = DrawerState.closed;
          break;
        case AnimationStatus.forward:
          standardDrawerState = DrawerState.opening;
          break;
        case AnimationStatus.reverse:
          standardDrawerState = DrawerState.closing;
          break;
      }
      context.read<ShellState>().standardDrawerState = standardDrawerState;
    });

    standardDrawerWidth = Tween<double>(begin: 0, end: standardDrawerMaxWidth)
        .animate(standardDrawerController);
    standardDrawerWidth.addListener(() {
      setState(() {});
    });
    appBarSpacing = Tween<double>(begin: 0, end: standardDrawerMaxWidth - 56)
        .animate(standardDrawerController);
    appBarSpacing.addListener(() {
      setState(() {});
    });

    scrollController.addListener(() {
      if (scrollController.offset > 0) {
        isAppBarElevated = true;
        setState(() {});
      } else if (isAppBarElevated) {
        isAppBarElevated = false;
        setState(() {});
      }
    });
  }

  void buildState(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    width = size.width;
    usefulWidth = size.width - standardDrawerWidth.value;
    height = size.height;

    if (width < 720) {
      gutters = 24;
      appBarMargins = 0;
    } else {
      gutters = 24;
      appBarMargins = 24;
    }

    webLayoutMinWidth = maxContentWidth + standardDrawerMaxWidth + gutters * 2;

    isMobileLayout = width < webLayoutMinWidth;

    if (usefulWidth < maxContentWidth + gutters * 2) {
      if (usefulWidth < maxContentWidth)
        margins = 0;
      else
        margins = gutters;
    } else {
      margins = (usefulWidth - maxContentWidth) / 2;
    }

    contentWidth = usefulWidth - margins * 2;

    if (margins == 0)
      cardCornerRadius = 0;
    else
      cardCornerRadius = gutters / 4;

    if (isMobileLayout && !standardDrawerController.isDismissed) {
      if (isInitialized)
        standardDrawerController.fling(velocity: -1);
      else {
        standardDrawerController.value = 0;
        standardDrawerState = DrawerState.closed;
      }
    }

    if (!isInitialized) {
      isInitialized = true;
      standardDrawerState = DrawerState.open;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Claim priority, If there are parallel sub router, you will need
    // to pick which one should take priority;
    _backButtonDispatcher.takePriority();

    buildState(context);

    return Scaffold(
      appBar: AppBar(
        elevation: isAppBarElevated ? 4 : 0,
        backgroundColor: isAppBarElevated
            ? Theme.of(context).appBarTheme.backgroundColor
            : Theme.of(context).backgroundColor,
        leadingWidth: 56 + appBarMargins,
        title: Padding(
            padding: EdgeInsets.only(left: appBarSpacing.value),
            child: Text('The Duckling') //Text("To Papáki"),
            ),
        leading: !displayMobileLayout
            ? IconButton(
                icon: AnimatedIcon(
                  progress: standardDrawerController,
                  icon: AnimatedIcons.menu_close,
                ),
                onPressed: () => toggleDrawer(context))
            : null,
      ),
      drawer: displayMobileLayout ? buildModalDrawer() : null,
      body: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        buildStandardDrawer(),
        Expanded(
          child: Router(
            routerDelegate: _routerDelegate,
            backButtonDispatcher: _backButtonDispatcher,
          ),
        ),
      ]),
    );
  }

  void toggleDrawer(BuildContext context) {
    print('Pressed button');
    print(standardDrawerState);
    switch (standardDrawerState) {
      case DrawerState.closed:
        {
          standardDrawerController.fling();
          print('Opened drawer');
        }
        break;
      case DrawerState.closing:
        {
          standardDrawerController.fling();
          print('Opened drawer');
        }
        break;
      case DrawerState.open:
        {
          standardDrawerController.fling(velocity: -1);
        }
        break;
      case DrawerState.opening:
        {
          standardDrawerController.fling(velocity: -1);
        }
        break;
    }
  }

  Widget buildStandardDrawer() {
    return Container(
      width: standardDrawerWidth.value + 0.1,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: NeverScrollableScrollPhysics(),
        child: Row(
          children: [
            Container(
              width: 256,
              child: Drawer(
                elevation: 0,
                child: ListView(children: buildDrawerChildren()),
              ),
            ),
            // if (!isMobileLayout) VerticalDivider(width: 0),
          ],
        ),
      ),
    );
  }

  Widget buildModalDrawer() {
    return Drawer(
        child: ListTileTheme(
      style: ListTileStyle.list,
      child: ListView(
        children: <Widget>[
              AppBar(
                elevation: 16,
                shadowColor: Colors.transparent,
                backgroundColor: Theme.of(context).canvasColor,
                leadingWidth: 56 + appBarMargins,
                title: Padding(
                    padding: EdgeInsets.only(left: appBarSpacing.value),
                    child: Text('The Duckling') //Text("To Papáki"),
                    ),
                leading: IconButton(
                    icon: Icon(
                      Icons.close,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ),
            ] +
            buildDrawerChildren(),
      ),
    ));
  }

  List<Widget> buildDrawerChildren() {
    final result = <Widget>[];
    var topGutters = true;

    for (var menu in AppMenu.values) {
      result.add(
        Padding(
          padding:
              EdgeInsets.only(left: gutters, top: topGutters ? gutters : 0),
          child: Consumer<AppState>(
            builder: (context, state, _) => ListTile(
              selected: menu == state.selectedMenu,
              title: Text(menu.name),
              onTap: () {
                widget.handleMenuTapped(menu);
              },
            ),
          ),
        ),
      );
      topGutters = false;
    }

    return result;
  }
}

class FadeAnimationPage extends Page {
  final Widget child;

  FadeAnimationPage({Key key, this.child}) : super(key: key);

  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, animation2) {
        var curveTween = CurveTween(curve: Curves.easeIn);
        return FadeTransition(
          key: key,
          opacity: animation.drive(curveTween),
          child: child,
        );
      },
    );
  }
}

/// Handles navigation inside the menus
class InnerRouterDelegate extends RouterDelegate<BlogPath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BlogPath> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  InnerRouterDelegate();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, appState, _) {
      return Navigator(
        key: navigatorKey,
        pages: [
          //TODO
          if (appState.selectedMenu == AppMenu.home)
            MaterialPage(
                key: ValueKey('HomeScreen1'),
                child: HomeScreen(key: ValueKey('HomeScreen'))),
          if (appState.selectedMenu != AppMenu.home)
            MaterialPage(child: Container())
        ],
        onPopPage: (route, value) {
          return true;
        }, // doesn't need to handle pops
      );
    });
  }

  @override
  Future<void> setNewRoutePath(BlogPath path) async {
    // This is not required for inner router delegate because it does not
    // parse route
    assert(false);
  }
}
