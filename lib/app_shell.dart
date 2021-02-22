import 'package:flutter/material.dart';
import 'app_state.dart';
import 'home_page.dart';
import 'classes.dart';

class ShellState extends ChangeNotifier {
  /// These states are super private because I want
  /// private setters so that only the _AppShellState can change them
  /// I need setters because I must call notifyListeners()
  bool __isMobileLayout;
  double __margins;
  double __gutters;
  double __cardCornerRadius;
  DrawerState __standardDrawerState;
  List<Article> articles = <Article>[];
  ScrollController scrollController = ScrollController();

  bool get isMobileLayout => __isMobileLayout;
  double get margins => __margins;
  double get gutters => __gutters;
  double get cardCornerRadius => __cardCornerRadius;
  DrawerState get standardDrawerState => __standardDrawerState;

  bool get displayMobileLayout {
    return isMobileLayout && standardDrawerState == DrawerState.closed;
  }

  set _isMobileLayout(bool value) {
    __isMobileLayout = value;
    notifyListeners();
  }

  set _margins(double value) {
    __margins = value;
    notifyListeners();
  }

  set _gutters(double value) {
    __gutters = value;
    notifyListeners();
  }

  set _cardCornerRadius(double value) {
    __cardCornerRadius = value;
    notifyListeners();
  }

  set _standardDrawerState(DrawerState value) {
    __standardDrawerState = value;
    notifyListeners();
  }
}

class AppShell extends StatefulWidget {
  final AppState appState;
  final void Function(AppMenu) handleMenuTapped;

  AppShell({
    @required this.appState,
    @required this.handleMenuTapped,
  });

  @override
  _AppShellState createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  // my state
  ShellState shellState = ShellState();

  /// These are the variables that need ot be in shellState.
  /// If we need more we can just add more.

  bool get isMobileLayout => shellState.isMobileLayout;
  bool get displayMobileLayout => shellState.displayMobileLayout;
  double get margins => shellState.margins;
  double get gutters => shellState.gutters;
  double get cardCornerRadius => shellState.cardCornerRadius;
  DrawerState get standardDrawerState => shellState.standardDrawerState;
  List<Article> get articles => shellState.articles;
  ScrollController get scrollController => shellState.scrollController;

  set isMobileLayout(bool value) {
    shellState._isMobileLayout = value;
  }

  set margins(double value) {
    shellState._margins = value;
  }

  set gutters(double value) {
    shellState._gutters = value;
  }

  set cardCornerRadius(double value) {
    shellState._cardCornerRadius = value;
  }

  set standardDrawerState(DrawerState value) {
    shellState._standardDrawerState = value;
  }

  double width, height, usefulWidth, usefulHeight;
  double appBarMargins;
  double maxContentWidth = 600;
  double contentWidth;
  double webLayoutMinWidth;
  double standardDrawerMaxWidth = 144;

  bool isInitialized = false;
  bool isAppBarElevated = false;

  AnimationController standardDrawerController;
  Animation<double> standardDrawerWidth;
  Animation<double> appBarSpacing;

  //for the delegate
  InnerRouterDelegate _routerDelegate;
  ChildBackButtonDispatcher _backButtonDispatcher;

  void initState() {
    super.initState();
    _routerDelegate =
        InnerRouterDelegate(appState: widget.appState, shellState: shellState);

    standardDrawerState = DrawerState.open;
    standardDrawerController = AnimationController(
        value: 1.0, vsync: this, duration: Duration(milliseconds: 500));
    standardDrawerController.addStatusListener((status) {
      setState(() {
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
      });
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
        setState(() {
          isAppBarElevated = true;
        });
      } else if (isAppBarElevated) {
        setState(() {
          isAppBarElevated = false;
        });
      }
    });

    widget.appState.areArticlesLoaded.then((value) {
      for (var article in widget.appState.articles.values)
        articles.add(article);
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _routerDelegate.appState = widget.appState;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Defer back button dispatching to the child router
    _backButtonDispatcher = Router.of(context)
        .backButtonDispatcher
        .createChildBackButtonDispatcher();
  }

  void buildState(BuildContext context) {
    setState(() {
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

      webLayoutMinWidth =
          maxContentWidth + standardDrawerMaxWidth + gutters * 2;

      isMobileLayout = width < webLayoutMinWidth;

      if (usefulWidth < maxContentWidth + gutters * 2) {
        if (usefulWidth < maxContentWidth)
          margins = 0;
        else
          margins = gutters;
      } else {
        margins = (usefulWidth - maxContentWidth) / 2;
      }

      if (isMobileLayout && !standardDrawerController.isDismissed) {
        if (isInitialized)
          standardDrawerController.fling(velocity: -1);
        else {
          standardDrawerController.value = 0;
          standardDrawerState = DrawerState.closed;
        }
      }

      contentWidth = usefulWidth - margins * 2;

      if (margins == 0)
        cardCornerRadius = 0;
      else
        cardCornerRadius = gutters / 4;

      isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = widget.appState;

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
                onPressed: toggleDrawer)
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

  void toggleDrawer() {
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
          child: ListTile(
            selected: menu == widget.appState.selectedMenu,
            title: Text(menu.name),
            onTap: () {
              widget.handleMenuTapped(menu);
            },
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
  AppState get appState => _appState;
  AppState _appState;
  ShellState shellState;

  set appState(AppState value) {
    if (value == _appState) {
      return;
    }
    _appState = value;
    notifyListeners();
  }

  InnerRouterDelegate(
      {@required AppState appState, @required this.shellState}) {
    this._appState = appState;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        //TODO
        if (appState.selectedMenu == AppMenu.home)
          MaterialPage(
              key: ValueKey('HomeScreen'),
              child: HomeScreen(
                  key: ValueKey('HomeScreen'),
                  shellState: shellState,
                  onArticleTapped: _handleArticleTapped)),
        if (appState.selectedMenu != AppMenu.home)
          MaterialPage(child: Container())
      ],
      onPopPage: (route, value) {
        return true;
      }, // doesn't need to handle pops
    );
  }

  @override
  Future<void> setNewRoutePath(BlogPath path) async {
    // This is not required for inner router delegate because it does not
    // parse route
    assert(false);
  }

  void _handleArticleTapped(Article article) {
    appState.selectedArticle = article;
    notifyListeners();
  }
}
