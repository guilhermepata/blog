import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'article_page.dart';
import 'classes.dart';
import 'app_shell.dart';

class AppState extends ChangeNotifier {
  final List<String> assets = [];
  final Map<String/*!*/, Article> articles = Map();
  Article _selectedArticle;
  AppMenu _selectedMenu;
  bool _areArticlesLoading = false;
  Future<bool>/*!*/ _areArticlesLoaded;

  bool _isThemeFlipped = false;

  AppState() {
    _areArticlesLoaded = loadArticles();
    _areArticlesLoading = true;
    _selectedMenu = AppMenu.home;
  }

  static Map<String, dynamic> jsonDecode(String string) {
    return json.decode(string);
  }

  static List<String> getArticlePaths(Map<String, dynamic> manifestMap) {
    return manifestMap.keys
        .where((String key) => key.contains('posts/'))
        .where((String key) => key.contains('.md'))
        .toList();
  }

  Future<bool> loadArticles() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap =
        await compute(jsonDecode, manifestContent);
    // >> To get paths you need these 2 lines

    final articlePaths = await compute(getArticlePaths, manifestMap);

    assets.addAll(articlePaths);

    for (var asset in assets)
      await Article.fromAsset(asset).then((article) {
        articles[article.title] = article;
        notifyListeners();
      });
    _areArticlesLoading = false;
    notifyListeners();
    return true;
  }

  bool get areArticlesLoading => _areArticlesLoading;
  Future<bool> get areArticlesLoaded => _areArticlesLoaded;

  Article get selectedArticle => _selectedArticle;

  set selectedArticle(Article article) {
    _selectedArticle = article;
    notifyListeners();
  }

  AppMenu get selectedMenu => _selectedMenu;

  bool get isThemeFlipped => _isThemeFlipped;

  set selectedMenu(AppMenu menu) {
    _selectedMenu = menu;
    notifyListeners();
  }

  set isThemeFlipped(bool value) {
    _isThemeFlipped = value;
    notifyListeners();
  }

  void flipTheme() {
    isThemeFlipped = !isThemeFlipped;
  }

  void setSelectedArticleByTitle(String title) {
    selectedArticle = articles[title];
  }

  Future<void> setSelectedArticleByUrl(String/*!*/ urlTitle) async {
    await _areArticlesLoaded;
    for (var title in articles.keys) {
      if (urlTitle.isUrlOf(title)) {
        selectedArticle = articles[title];
        return;
      }
    }
    if (selectedArticle == null) selectedMenu = null;
    // if we reach this line, the title doesn't exist
    assert(true, 'Should print a 404');
  }

  setSelectedMenuByIndex(int index) {
    selectedMenu = AppMenu.values[index];
  }
}

class BlogRouteInformationParser extends RouteInformationParser<BlogPath> {
  @override
  Future<BlogPath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location);

    if (uri.pathSegments.isNotEmpty) {
      if (uri.pathSegments.length == 1) {
        if (uri.pathSegments.first == 'about') {
          return BlogAboutPath();
        } else if (uri.pathSegments.first == 'essays') {
          return BlogEssaysPath();
        } else if (uri.pathSegments.first == 'projects') {
          return BlogProjectsPath();
        } else
          return UnknownPath();
      } else if (uri.pathSegments.length == 2) {
        if (uri.pathSegments.first == 'essays') {
          return BlogArticlePath.fromUrl(uri.pathSegments[1]);
        } else
          return UnknownPath();
      }
    } else {
      return BlogHomePath();
    }
  }

  @override
  RouteInformation restoreRouteInformation(BlogPath configuration) {
    if (configuration is BlogHomePath) {
      return RouteInformation(location: '/');
    } else if (configuration is BlogAboutPath) {
      // print('I tried setting the route to about');
      return RouteInformation(location: '/about');
    } else if (configuration is BlogEssaysPath) {
      return RouteInformation(location: '/essays');
    } else if (configuration is BlogProjectsPath) {
      return RouteInformation(location: '/projects');
    } else if (configuration is BlogArticlePath) {
      return RouteInformation(location: '/essays/${configuration.urlTitle}');
    } else if (configuration is UnknownPath) {
      return RouteInformation(location: '/404/');
    }
    return null;
  }
}

abstract class BlogPath {}

class UnknownPath extends BlogPath {}

class BlogHomePath extends BlogPath {}

class BlogAboutPath extends BlogPath {}

class BlogEssaysPath extends BlogPath {}

class BlogProjectsPath extends BlogPath {}

class BlogArticlePath extends BlogPath {
  String _urlTitle;
  String _title;
  bool isFromUrl = false;
  bool isFromTitle = false;

  BlogArticlePath.fromTitle(String title) {
    this._title = title;
    var parts = title.split((RegExp(r'[ —]')));
    this._urlTitle = parts
        .sublist(0, parts.length < 5 ? parts.length : 5)
        .reduce((value, element) => value + '_' + element)
        .toLowerCase();
    isFromTitle = true;
  }

  BlogArticlePath.fromUrl(String urlTitle) {
    var parts = urlTitle.split('_');
    this._urlTitle = parts
        .sublist(0, parts.length < 5 ? parts.length : 5)
        .reduce((value, element) => value + '_' + element)
        .toLowerCase();
    isFromUrl = true;
  }

  String get urlTitle => _urlTitle;
  String get title => _title;
}

/// Handles the URL and navigation outside the menus
class BlogRouterDelegate extends RouterDelegate<BlogPath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BlogPath> {
  final GlobalKey<NavigatorState> navigatorKey;
  final AppState appState;

  BlogRouterDelegate(AppState appState)
      : this.navigatorKey = GlobalKey<NavigatorState>(),
        this.appState = appState;

  // When the app state changes, the configuration is updated
  BlogPath get currentConfiguration {
    if (appState.selectedArticle == null) {
      // print('I tried to change the config');
      return appState.selectedMenu.configuration;
    } else {
      return BlogArticlePath.fromTitle(appState.selectedArticle.title);
    }
  }

  @override
  Widget build(BuildContext context) {
    // return Consumer<AppState>(
    //   builder: (context, appState, _) {
    //     },
    // );

    return Navigator(
      key: navigatorKey,
      pages: appState.areArticlesLoading
          ? [
              FadeAnimationPage(
                  child: LoadingScreen(
                    key: ValueKey('Loading1'),
                  ),
                  key: ValueKey('Loading'))
            ]
          : [
              if (appState.selectedMenu != null)
                FadeAnimationPage(
                  child: AppShell(
                      onMenuTapped: _handleMenuTapped,
                      onArticleTapped: _handleArticleTapped),
                  key: ValueKey('AppShell'),
                ),
              if (appState.selectedArticle != null)
                FadeAnimationPage(
                    child: ArticlePage(
                      key: ValueKey(appState.selectedArticle.title + '1'),
                      article: appState.selectedArticle,
                    ),
                    key: ValueKey(appState.selectedArticle.title)),
              if (appState.selectedArticle == null &&
                  appState.selectedMenu == null)
                //TODO
                // must design unknown page
                FadeAnimationPage(child: UnknownPage()),
            ],
      onPopPage: _onPopPage,
    );
  }

  bool _onPopPage(route, result) {
    if (!route.didPop(result)) {
      return false;
    }

    if (appState.selectedArticle != null) {
      appState.selectedArticle = null;
    }
    if (appState.selectedMenu == null) {
      appState.selectedMenu = AppMenu.home;
    }
    notifyListeners();
    return true;
  }

  void _handleMenuTapped(AppMenu menu) {
    appState.selectedMenu = menu;
    notifyListeners();
  }

  void _handleArticleTapped(Article article) {
    appState.selectedArticle = article;
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(BlogPath path) async {
    if (path is BlogArticlePath) {
      await appState.setSelectedArticleByUrl(path.urlTitle);
      notifyListeners();
    } else {
      appState.selectedArticle = null;
      appState.selectedMenu = AppMenuParser.fromPath(path);
      notifyListeners();
    }
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({
    Key key,
  }) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class UnknownPage extends StatelessWidget {
  const UnknownPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    var imageWidth;
    var messageWidth = 300.0;

    if (width > height * 1.5) {
      imageWidth = width - messageWidth - 48;
    } else {
      imageWidth = width - 48;
      messageWidth = width - 48;
    }
    if (messageWidth == 300.0 && imageWidth > 600) imageWidth = 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //   elevation: 0,
      //   // title: Text('The Duckling'),
      // ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: height),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                // spacing: 56,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 48),
                    child: Container(
                      width: messageWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 0, left: 16),
                            child: Text('404',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(.6),
                                        fontSize: 40,
                                        fontFamily:
                                            GoogleFonts.roboto().fontFamily,
                                        fontWeight: FontWeight.w100)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('Lost in space',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(fontSize: 50)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, left: 16, right: 16, bottom: 24),
                            child: Text(
                                "You have reached the edge of the Universe. The page you requested could not be found... But don't worry, you can return to the previous page.",
                                textAlign: TextAlign.left,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(.6),
                                    )),
                          ),
                          ButtonBar(
                            // alignment: MainAxisAlignment.start,
                            // mainAxisSize: MainAxisSize.min,
                            buttonPadding: EdgeInsets.all(16),
                            children: [
                              OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Go back')),
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Go home')),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: imageWidth, maxWidth: imageWidth),
                    child: Image.asset(
                        Theme.of(context).brightness == Brightness.light
                            ? 'images/image404_light.png'
                            : 'images/image404_dark.png'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension StringCompare on String {
  bool containsLowerCase(String substring) {
    final bigstring = this.toLowerCase();
    substring = substring.toLowerCase();
    return bigstring.contains(substring);
  }

  bool isUrlOf(String biggerString) {
    final bigParts = biggerString.split(RegExp(r'[ —]'));
    final smallParts = this.split(RegExp(r'[_]'));
    if (smallParts.length < 5 && smallParts.length < bigParts.length)
      return false;
    biggerString = bigParts.reduce((value, element) => value + ' ' + element);
    final substring =
        smallParts.reduce((value, element) => value + ' ' + element);
    return biggerString.containsLowerCase(substring);
  }
}

enum AppMenu { home, about, essays, projects }

extension AppMenuParser on AppMenu {
  String get name {
    switch (this) {
      case AppMenu.home:
        return 'Home';
        break;
      case AppMenu.about:
        return 'About';
        break;
      case AppMenu.essays:
        return 'Essays';
        break;
      case AppMenu.projects:
        return 'Projects';
        break;
      default:
        return '';
        break;
    }
  }

  BlogPath get configuration {
    switch (this) {
      case AppMenu.home:
        return BlogHomePath();
        break;
      case AppMenu.about:
        return BlogAboutPath();
        break;
      case AppMenu.essays:
        return BlogEssaysPath();
        break;
      case AppMenu.projects:
        return BlogProjectsPath();
        break;
      default:
        return UnknownPath();
        break;
    }
  }

  static AppMenu fromPath(BlogPath path) {
    if (path is BlogHomePath) {
      return AppMenu.home;
    }
    if (path is BlogAboutPath) {
      return AppMenu.about;
    }
    if (path is BlogEssaysPath) {
      return AppMenu.essays;
    }
    if (path is BlogProjectsPath) {
      return AppMenu.projects;
    }
    if (path is UnknownPath) {
      return null;
    } else
      return null;
  }
}
