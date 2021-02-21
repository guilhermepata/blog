import 'package:flutter/material.dart';
import 'app_state.dart';
import 'home_page.dart';
import 'classes.dart';

class AppShell extends StatefulWidget {
  final AppState appState;

  AppShell({
    @required this.appState,
  });

  @override
  _AppShellState createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  InnerRouterDelegate _routerDelegate;
  ChildBackButtonDispatcher _backButtonDispatcher;

  void initState() {
    super.initState();
    _routerDelegate = InnerRouterDelegate(widget.appState);
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

  @override
  Widget build(BuildContext context) {
    var appState = widget.appState;

    // Claim priority, If there are parallel sub router, you will need
    // to pick which one should take priority;
    _backButtonDispatcher.takePriority();

    return Scaffold(
      body: Router(
        routerDelegate: _routerDelegate,
        backButtonDispatcher: _backButtonDispatcher,
      ),
    );
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

  set appState(AppState value) {
    if (value == _appState) {
      return;
    }
    _appState = value;
    notifyListeners();
  }

  InnerRouterDelegate(this._appState);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        //TODO
        FadeAnimationPage(
            child: HomePage(onArticleTapped: _handleArticleTapped))
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
