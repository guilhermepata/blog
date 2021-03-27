import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'feather_icon_icons.dart';
import 'app_state.dart';
import 'home_page.dart';
import 'classes.dart';
import 'about_page.dart';
import 'essays_page.dart';
import 'projects_page.dart';

class ShellState extends ChangeNotifier {
  final BuildContext context;

  bool _isMobileLayout = false;
  // double _margins = 0;
  double _gutters = 24;
  double _cardCornerRadius = 0;
  StandardDrawerState _standardDrawerState = StandardDrawerState.closed;
  List<Article> articles = <Article>[];
  // ScrollController scrollController = ScrollController();
  Fling _appBarFlinger = Fling.none;

  ValueNotifier pastTitleNotifier = ValueNotifier(false);

  bool _areArticlesLoaded = false;

  ShellState(this.context) {
    context.read<AppState>().areArticlesLoaded.then((value) {
      for (var article in context.read<AppState>().articles.values)
        articles.add(article);
      _areArticlesLoaded = true;
      notifyListeners();
    });
  }

  bool get isMobileLayout => _isMobileLayout;
  // double get margins => _margins;
  double get gutters => _gutters;
  double get cardCornerRadius => _cardCornerRadius;
  StandardDrawerState get standardDrawerState => _standardDrawerState;

  bool get areArticlesLoaded => _areArticlesLoaded;

  Fling get appBarFlinger => _appBarFlinger;

  bool get displayMobileLayout {
    return (isMobileLayout) &&
        (standardDrawerState == StandardDrawerState.closed);
  }

  set isMobileLayout(bool value) {
    _isMobileLayout = value;
    notifyListeners();
  }

  // set margins(double value) {
  //   _margins = value;
  //   // print('Margins changed');
  //   notifyListeners();
  // }

  set gutters(double value) {
    _gutters = value;
    notifyListeners();
  }

  set cardCornerRadius(double value) {
    _cardCornerRadius = value;
    notifyListeners();
  }

  set standardDrawerState(StandardDrawerState value) {
    _standardDrawerState = value;
    notifyListeners();
  }

  set appBarFlinger(Fling value) {
    _appBarFlinger = value;
    notifyListeners();
  }
}

enum Fling { forward, backward, none }

enum AppBarState { raised, raising, lowered, lowering }

class AppShell extends StatefulWidget {
  final void Function(AppMenu) onMenuTapped;
  final void Function(Article) onArticleTapped;

  AppShell({required this.onMenuTapped, required this.onArticleTapped});

  @override
  _AppShellState createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  //
  late ShellState shellState;

  //

  late bool _isMobileLayout;
  late double _margins;
  late double _gutters;
  late double _cardCornerRadius;
  late StandardDrawerState _standardDrawerState;
  // List<Article> articles = <Article>[];
  // ScrollController scrollController = ScrollController();

  bool get isMobileLayout => _isMobileLayout;
  double get margins => _margins;
  double get gutters => _gutters;
  double get cardCornerRadius => _cardCornerRadius;
  StandardDrawerState get standardDrawerState => _standardDrawerState;

  set isMobileLayout(bool value) {
    _isMobileLayout = value;
    shellState.isMobileLayout = value;
  }

  // set margins(double value) {
  //   // setState(() {
  //   _margins = value;
  //   // shellState.margins = value;
  //   // });
  // }

  set gutters(double value) {
    _gutters = value;
    shellState.gutters = value;
  }

  set cardCornerRadius(double value) {
    _cardCornerRadius = value;
    shellState.cardCornerRadius = value;
  }

  set standardDrawerState(StandardDrawerState value) {
    _standardDrawerState = value;
    shellState.standardDrawerState = value;
  }

  // rigth now these don't need to notify the listeners, I think
  late double width, height, usefulWidth, usefulHeight;
  late double appBarMargins;
  double maxContentWidth = 600;
  // double contentWidth;
  late double webLayoutMinWidth;
  double standardDrawerMaxWidth = 144 + 8.0;

  bool isInitialized = false;
  bool isAppBarElevated = false;
  // late AnimationController appBarStateController;
  late Animation<Color?> appBarColor;

  // AppBarState appBarState = AppBarState.lowered;

  //
  bool get displayMobileLayout {
    return isMobileLayout && standardDrawerState == StandardDrawerState.closed;
  }

  // Animations
  late AnimationController standardDrawerController;
  late Animation<double> standardDrawerWidth;
  late Animation<double> appBarSpacing;

  Brightness? brightness;

  //for the delegate
  late InnerRouterDelegate _routerDelegate;
  ChildBackButtonDispatcher? _backButtonDispatcher;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Defer back button dispatching to the child router
    _backButtonDispatcher = Router.of(context)
        .backButtonDispatcher!
        .createChildBackButtonDispatcher();
    brightness = Theme.of(context).brightness;
  }

  @override
  void initState() {
    super.initState();

    shellState = ShellState(context);

    // shellState.scrollController = scrollController;

    standardDrawerController = AnimationController(
        value: 1.0, vsync: this, duration: Duration(milliseconds: 500));
    standardDrawerController.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.completed:
          standardDrawerState = StandardDrawerState.open;
          break;
        case AnimationStatus.dismissed:
          standardDrawerState = StandardDrawerState.closed;
          break;
        case AnimationStatus.forward:
          standardDrawerState = StandardDrawerState.opening;
          break;
        case AnimationStatus.reverse:
          standardDrawerState = StandardDrawerState.closing;
          break;
      }
      shellState.standardDrawerState = standardDrawerState;
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

    // appBarStateController =
    //     AnimationController(vsync: this, duration: Duration(milliseconds: 50));
    // appBarStateController.addStatusListener((status) {
    //   if (status == AnimationStatus.completed)
    //     setState(() {
    //       isAppBarElevated = true;
    //       appBarState = AppBarState.raised;
    //     });
    //   else if (status == AnimationStatus.dismissed)
    //     setState(() {
    //       isAppBarElevated = false;
    //       appBarState = AppBarState.lowered;
    //     });
    //   else if (status == AnimationStatus.forward)
    //     setState(() {
    //       appBarState = AppBarState.raising;
    //     });
    //   else if (status == AnimationStatus.reverse)
    //     setState(() {
    //       appBarState = AppBarState.lowering;
    //     });
    // });
    // appBarStateController.addListener(() {
    //   setState(() {});
    // });

    // shellState.addListener(() {
    //   if (shellState.appBarFlinger == Fling.forward &&
    //       appBarState != AppBarState.raising &&
    //       appBarState != AppBarState.raised) {
    //     appBarStateController.fling();
    //     shellState.appBarFlinger = Fling.none;
    //   } else if (shellState.appBarFlinger == Fling.backward &&
    //       appBarState != AppBarState.lowering &&
    //       appBarState != AppBarState.lowered) {
    //     appBarStateController.fling(velocity: -1);
    //     shellState.appBarFlinger = Fling.none;
    //   }
    // });

    _routerDelegate = InnerRouterDelegate(
        onMenuTapped: widget.onMenuTapped,
        onArticleTapped: widget.onArticleTapped,
        shellState: shellState);
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

    isMobileLayout = width < 1023;

    if (!isMobileLayout && width < webLayoutMinWidth) isMobileLayout = true;

    // if (usefulWidth < maxContentWidth + gutters * 2) {
    //   if (usefulWidth < maxContentWidth)
    //     margins = 0;
    //   else
    //     margins = gutters;
    // } else {
    //   margins = (usefulWidth - maxContentWidth) / 2;
    // }

    // contentWidth = usefulWidth;

    if (usefulWidth < maxContentWidth)
      cardCornerRadius = 0;
    else
      cardCornerRadius = 0;

    if (!isInitialized) {
      standardDrawerState = StandardDrawerState.open;
    }

    if (isMobileLayout && !standardDrawerController.isDismissed) {
      if (isInitialized)
        standardDrawerController.fling(velocity: -1);
      else {
        standardDrawerController.value = 0;
        standardDrawerState = StandardDrawerState.closed;
      }
    }

    isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    // Claim priority, If there are parallel sub router, you will need
    // to pick which one should take priority;
    _backButtonDispatcher!.takePriority();

    buildState(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: ShellAppBar(
          displayMobileLayout: displayMobileLayout,
          appBarMargins: appBarMargins,
          appBarSpacing: appBarSpacing,
          standardDrawerController: standardDrawerController,
          pastTitleNotifier: shellState.pastTitleNotifier,
          onPressed: () => toggleDrawer(context),
        ),
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
    // print('Pressed button');
    // print(standardDrawerState);
    switch (standardDrawerState) {
      case StandardDrawerState.closed:
        {
          standardDrawerController.fling();
          // print('Opened drawer');
        }
        break;
      case StandardDrawerState.closing:
        {
          standardDrawerController.fling();
          // print('Opened drawer');
        }
        break;
      case StandardDrawerState.open:
        {
          standardDrawerController.fling(velocity: -1);
        }
        break;
      case StandardDrawerState.opening:
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
                  child: Title(),
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
    final result = <Widget>[
      SizedBox(
        height: gutters,
      )
    ];

    for (var menu in AppMenu.values) {
      result.add(
        Consumer<AppState>(
          builder: (context, state, _) => ListTile(
            contentPadding:
                EdgeInsets.only(left: gutters + 16, right: gutters + 16),
            selected: menu == state.selectedMenu,
            title: Text(menu.name),
            onTap: () {
              if (menu != state.selectedMenu) {
                widget.onMenuTapped(menu);
                if (displayMobileLayout) Navigator.of(context).pop();
                shellState.pastTitleNotifier.value = false;
              }
            },
          ),
        ),
      );
      // result.add(
      //   Consumer<AppState>(
      //     builder: (context, state, _) => GestureDetector(
      //       onTap: () {
      //         widget.onMenuTapped(menu);
      //         if (displayMobileLayout) Navigator.of(context).pop();
      //         shellState.pastTitleNotifier.value = false;
      //       },
      //       child: Padding(
      //         padding: EdgeInsets.only(left: gutters + 16, right: gutters + 16),
      //         child: Container(
      //           child: Text(menu.name),
      //           // onTap: () {
      //           //   widget.onMenuTapped(menu);
      //           //   if (displayMobileLayout) Navigator.of(context).pop();
      //           //   shellState.pastTitleNotifier.value = false;
      //           // },
      //         ),
      //       ),
      //     ),
      //   ),
      // );
      // topGutters = false;
    }

    return result;
  }
}

enum AppBarMenuOptions { changeTheme }

enum StandardDrawerState { closed, closing, open, opening }

class FadeAnimationPage extends Page {
  final Widget? child;

  FadeAnimationPage({Key? key, this.child}) : super(key: key as LocalKey?);

  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) {
        var curveTween = CurveTween(curve: Curves.easeIn);
        return FadeThroughTransition(
          // fillColor: Theme.of(context).backgroundColor,
          // key: key,
          // opacity: animation.drive(curveTween),
          animation: animation,
          secondaryAnimation: secondaryAnimation,
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

  final void Function(AppMenu) onMenuTapped;
  final void Function(Article) onArticleTapped;
  final ShellState shellState;

  InnerRouterDelegate(
      {required this.onMenuTapped,
      required this.onArticleTapped,
      required this.shellState});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: shellState,
      child: Consumer<AppState>(builder: (context, appState, _) {
        return Navigator(
          key: navigatorKey,
          pages: (appState.selectedMenu == AppMenu.home)
              ? [
                  FadeAnimationPage(
                    key: ValueKey('HomeScreen1'),
                    child: HomeScreen(
                      key: ValueKey('HomeScreen'),
                      onArticleTapped: onArticleTapped,
                    ),
                  ),
                ]
              : (appState.selectedMenu == AppMenu.about)
                  ? [
                      FadeAnimationPage(
                        key: ValueKey('About1'),
                        child: AboutPage(
                          key: ValueKey('About'),
                          onMenuTapped: onMenuTapped,
                        ),
                      ),
                    ]
                  : (appState.selectedMenu == AppMenu.essays)
                      ? [
                          FadeAnimationPage(
                            key: ValueKey('EssaysScreen1'),
                            child: EssaysScreen(
                              key: ValueKey('EssaysScreen'),
                              onArticleTapped: onArticleTapped,
                            ),
                          ),
                        ]
                      : (appState.selectedMenu == AppMenu.projects)
                          ? [
                              FadeAnimationPage(
                                key: ValueKey('ProjectsScreen1'),
                                child: ProjectsScreen(
                                  key: ValueKey('ProjectsScreen'),
                                ),
                              ),
                            ]
                          : [
                              FadeAnimationPage(
                                key: ValueKey('Else'),
                                child: Container(),
                              ),
                            ],
          onPopPage: (route, value) {
            return true;
          }, // doesn't need to handle pops
        );
      }),
    );
  }

  // void _handleArticleTapped(Article article) {
  //   onArticleTapped(article);
  //   notifyListeners();
  // }

  @override
  Future<void> setNewRoutePath(BlogPath path) async {
    // This is not required for inner router delegate because it does not
    // parse route
    assert(false);
  }
}

class ShellAppBar extends StatefulWidget {
  const ShellAppBar({
    Key? key,
    // required this.title,
    required this.displayMobileLayout,
    required this.appBarMargins,
    required this.appBarSpacing,
    required this.standardDrawerController,
    required this.pastTitleNotifier,
    required this.onPressed,
  }) : super(key: key);

  // final String title;
  final bool displayMobileLayout;
  final double appBarMargins;
  final Animation appBarSpacing;
  final AnimationController standardDrawerController;
  final ValueNotifier pastTitleNotifier;
  final void Function() onPressed;

  @override
  _ShellAppBarState createState() => _ShellAppBarState();
}

class _ShellAppBarState extends State<ShellAppBar>
    with SingleTickerProviderStateMixin {
  bool isAppBarElevated = false;
  late AnimationController appBarStateController;
  late Animation<Color?> appBarColor;
  late Animation<Color?> appBarForegroundColor;
  AppBarState appBarState = AppBarState.lowered;

  @override
  void initState() {
    widget.pastTitleNotifier.addListener(() {
      if (widget.pastTitleNotifier.value == true &&
          appBarState != AppBarState.raised &&
          appBarState != AppBarState.raising) {
        appBarStateController.fling();
      } else if (widget.pastTitleNotifier.value == false &&
          appBarState != AppBarState.lowered &&
          appBarState != AppBarState.lowering) {
        appBarStateController.fling(velocity: -1);
      }
    });

    appBarStateController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 50));
    appBarStateController.addStatusListener((status) {
      if (status == AnimationStatus.completed)
        setState(() {
          appBarState = AppBarState.raised;
          isAppBarElevated = true;
        });
      else if (status == AnimationStatus.dismissed)
        setState(() {
          appBarState = AppBarState.lowered;
          isAppBarElevated = false;
        });
      else if (status == AnimationStatus.forward)
        setState(() {
          appBarState = AppBarState.raising;
        });
      else if (status == AnimationStatus.reverse)
        setState(() {
          appBarState = AppBarState.lowering;
        });
    });
    appBarStateController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appBarColor = ColorTween(
            begin: Colors.transparent,
            end: Color.alphaBlend(Colors.white.withOpacity(.09),
                Theme.of(context).colorScheme.surface))
        .animate(appBarStateController);
    appBarColor.addListener(() {
      setState(() {});
    });
    appBarForegroundColor = ColorTween(
            begin: Colors.white,
            end: Theme.of(context).appBarTheme.foregroundColor)
        .animate(appBarStateController);
    appBarForegroundColor.addListener(() {
      setState(() {});
    });
    setState(() {
      appBarColor = ColorTween(
              begin: Theme.of(context).colorScheme.background,
              end: Color.alphaBlend(Colors.white.withOpacity(.0),
                  Theme.of(context).colorScheme.surface))
          .animate(appBarStateController);
      appBarColor.addListener(() {
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    appBarStateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: appBarStateController.value * 4,
      actions: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: PopupMenuButton<AppBarMenuOptions>(
              onSelected: (AppBarMenuOptions result) {
                if (result == AppBarMenuOptions.changeTheme) {
                  context.read<AppState>().flipTheme();
                }
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<AppBarMenuOptions>>[
                PopupMenuItem<AppBarMenuOptions>(
                  value: AppBarMenuOptions.changeTheme,
                  child: ListTile(
                    dense: true,
                    // visualDensity:
                    //     VisualDensity(horizontal: -4, vertical: -4),
                    minLeadingWidth: 18,
                    contentPadding: EdgeInsets.symmetric(horizontal: 0),
                    horizontalTitleGap: 8,
                    leading: Icon(
                      Theme.of(context).brightness == Brightness.dark
                          ? Icons.brightness_7
                          : Icons.brightness_4,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(.87),
                    ),
                    title: Text(
                      'Change theme',

                      // style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                ),
              ],
            ))
      ],
      backgroundColor: appBarColor.value,
      leadingWidth: 56 + widget.appBarMargins,
      title: Padding(
        padding: EdgeInsets.only(left: widget.appBarSpacing.value),
        child: Title(),
      ),
      leading: !widget.displayMobileLayout
          ? IconButton(
              icon: AnimatedIcon(
                progress: widget.standardDrawerController,
                icon: AnimatedIcons.menu_close,
              ),
              onPressed: widget.onPressed, //() => toggleDrawer(context)
            )
          : null,
    );
  }
}

class Title extends StatelessWidget {
  const Title({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          FeatherIcon.feather,
          size: 24,
        ),
        SizedBox(
          width: 4,
        ),
        Text.rich(
          TextSpan(
            text: 'The Duckling',
            style: GoogleFonts.lora(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(.87),
              fontSize: 19,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
            ),
            // children: [
            //   TextSpan(
            //     text: '.',
            //     style: TextStyle(
            //       color: Theme.of(context).colorScheme.primary,
            //     ),
            //   ),
            // ],
          ),
        ),
      ],
    );
  }
}
