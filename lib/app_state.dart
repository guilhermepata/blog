import 'package:flutter/material.dart';
import 'classes.dart';

class AppState extends ChangeNotifier {
  final List<String> assets = ["posts/finding_gender.md"];
  final Map<String, Article> articles = Map();
  Article _selectedArticle;
  AppMenu _selectedMenu;

  AppState() {
    for (var asset in assets)
      Article.fromAsset(asset).then((article) {
        articles[article.title] = article;
        notifyListeners();
      });
    _selectedMenu = AppMenu.home;
  }

  Article get selectedArticle => _selectedArticle;

  set selectedArticle(Article article) {
    _selectedArticle = article;
    notifyListeners();
  }

  AppMenu get selectedMenu => _selectedMenu;

  set selectedMenu(AppMenu menu) {
    _selectedMenu = menu;
    notifyListeners();
  }

  setSelectedArticleByTitle(String title) {
    selectedArticle = articles[title];
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

    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'settings') {
      return BlogAboutPath();
    } else {
      if (uri.pathSegments.length >= 2) {
        if (uri.pathSegments[0] == 'book') {
          return BlogArticlePath();
        }
      }
      return BlogHomePath();
    }
  }

  @override
  RouteInformation restoreRouteInformation(BlogPath configuration) {
    if (configuration is BlogHomePath) {
      return RouteInformation(location: '/');
    }
    if (configuration is BlogAboutPath) {
      return RouteInformation(location: '/about');
    }
    if (configuration is BlogArticlePath) {
      return RouteInformation(location: '/essays/');
    }
    return null;
  }
}

abstract class BlogPath {}

class BlogHomePath extends BlogPath {}

class BlogAboutPath extends BlogPath {}

class BlogEssaysPath extends BlogPath {}

class BlogProjectsPath extends BlogPath {}

class BlogArticlePath extends BlogPath {
  //TODO
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
}
