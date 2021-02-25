import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'classes.dart';
import 'themes.dart';
import 'article_page.dart';
import 'app_state.dart';
import 'home_page.dart';
import 'app_shell.dart';

Future<void> main() async {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => AppState()),
  ], child: BlogApp()));
}

class BlogApp extends StatefulWidget {
  @override
  _BlogAppState createState() => _BlogAppState();
}

class _BlogAppState extends State<BlogApp> {
  BlogRouterDelegate _routerDelegate;
  BlogRouteInformationParser _routeInformationParser =
      BlogRouteInformationParser();
  bool isInitialized = false;

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      _routerDelegate =
          BlogRouterDelegate(Provider.of<AppState>(context, listen: false));
      isInitialized = true;
    }

    return MaterialApp.router(
      title: 'The Duckling',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}
