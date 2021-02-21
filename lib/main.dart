import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'classes.dart';
import 'themes.dart';
import 'article_page.dart';
import 'app_state.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guilherme Pata',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  double width, height, usefulWidth, usefulHeight, margins, gutters;
  double appBarMargins;
  double maxContentWidth = 600;
  double contentWidth;
  double webLayoutMinWidth;
  double standardDrawerMaxWidth = 144;
  double cardCornerRadius;

  bool isInitialized = false;
  bool isMobileLayout;
  bool isAppBarElevated = false;

  List<Article> articles = <Article>[];

  DrawerState standardDrawerState;

  AnimationController standardDrawerController;
  Animation<double> standardDrawerWidth;
  Animation<double> appBarSpacing;

  ScrollController scrollController = ScrollController();

  bool get displayMobileLayout {
    return isMobileLayout && standardDrawerState == DrawerState.closed;
  }

  @override
  void initState() {
    super.initState();

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

    Article.fromAsset("posts/finding_gender.md").then((article) {
      setState(() {
        articles.add(article);
      });
    });
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

  @override
  Widget build(BuildContext context) {
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
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildStandardDrawer(),
          Expanded(
            child: Scrollbar(
              // thickness: 4
              isAlwaysShown: !displayMobileLayout,
              controller: scrollController,
              child: ListView(
                controller: scrollController,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: margins,
                        right: margins,
                        top: gutters,
                        bottom: gutters),
                    child: articles.isNotEmpty
                        ? ArticleCard(
                            articles[0],
                            cardCornerRadius: cardCornerRadius,
                            gutters: gutters,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
    final result = [];

    for (var menu in AppMenu.values) {
      result.add(
        Padding(
          padding: EdgeInsets.only(left: gutters, top: gutters),
          child: ListTile(
            selected: menu == AppMenu.home,
            title: Text(menu.name),
          ),
        ),
      );
    }

    return [
      Padding(
        padding: EdgeInsets.only(left: gutters, top: gutters),
        child: ListTile(
          selected: true,
          title: Text('Home'),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: gutters),
        child: ListTile(
          title: Text('About'),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: gutters),
        child: ListTile(
          title: Text('Essays'),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: gutters),
        child: ListTile(
          title: Text('Projects'),
        ),
      )
    ];
  }
}

class ArticleCard extends StatelessWidget {
  const ArticleCard(
    this.article, {
    Key key,
    @required this.cardCornerRadius,
    @required this.gutters,
  }) : super(key: key);

  final double cardCornerRadius;
  final double gutters;
  // final AsyncSnapshot<String> snapshot;
  final Article article;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: article.load(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(cardCornerRadius)),
            margin: EdgeInsets.zero,
            clipBehavior: Clip.hardEdge,
            child: Column(
              children: [
                CrossFadeWidgets(
                    showFirst: article.isLoaded,
                    firstChild: article.isLoaded
                        ? Image.network(
                            article.imageUrl,
                            frameBuilder: (BuildContext context, Widget child,
                                int frame, bool wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded ?? false) {
                                return child;
                              }
                              return Stack(
                                children: [
                                  Skeleton(
                                    width: 600,
                                    height: 600 / 21 * 9,
                                  ),
                                  AnimatedOpacity(
                                    child: child,
                                    opacity: frame == null ? 0 : 1,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeIn,
                                  ),
                                ],
                              );
                            },
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent progress) {
                              return Stack(
                                children: [
                                  if (progress != null)
                                    Skeleton(
                                      width: 600,
                                      height: 600 / 21 * 9,
                                    ),
                                  child
                                ],
                              );
                            },
                            semanticLabel: article.altText,
                            width: 600,
                            height: 600 / 21 * 9,
                            fit: BoxFit.cover,
                            // width: 300,
                          )
                        : null,
                    secondChild: Skeleton(
                      width: 600,
                      height: 600 / 21 * 9,
                    )),
                Padding(
                  padding: EdgeInsets.only(
                      top: gutters, left: gutters, right: gutters),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CrossFadeText(
                        article.isLoaded ? article.title : null,
                        showText: article.isLoaded,
                        style: Theme.of(context).textTheme.headline5,
                        // width: 200,
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      CrossFadeText(
                        article.isLoaded ? article.subtitle : null,
                        showText: article.isLoaded,
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(.54)),
                        // width: 300,
                      ),
                      SizedBox(height: 12),
                      Container(
                        height: 14 * 1.5 * 3.9,
                        child: CrossFadeTextWidgetBlock(
                            article.isLoaded
                                ? article
                                    .buildParagraphs(context,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(.54)),
                                        overflow: TextOverflow.fade,
                                        textAlign: TextAlign.justify)
                                    .first
                                : null,
                            showText: article.isLoaded,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(.54)),
                            overflow: TextOverflow.fade,
                            textAlign: TextAlign.justify),
                      ),
                    ],
                  ),
                ),
                CrossFadeWidgets(
                  showFirst: article.isLoaded,
                  firstChild: ButtonBar(
                    buttonPadding: EdgeInsets.all(gutters),
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ArticlePage(
                                          article: article,
                                        )));
                          },
                          child: Text('Read more')),
                    ],
                  ),
                  secondChild: ButtonBar(
                    buttonPadding: EdgeInsets.all(gutters),
                    children: [
                      ElevatedButton(onPressed: null, child: Text('Read more')),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class CrossFadeTextWidgetBlock extends StatelessWidget {
  final bool showText;
  final Widget textWidget;
  final TextStyle style;
  final double width;
  final int numLines;
  final TextOverflow overflow;
  final TextAlign textAlign;

  const CrossFadeTextWidgetBlock(
    this.textWidget, {
    Key key,
    @required this.showText,
    this.style,
    this.width,
    this.numLines = 5,
    this.overflow,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];

    for (var i = 0; i < numLines; i++) {
      children.add(
        Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            Text(
              ' ',
              style: style,
              textAlign: textAlign,
              overflow: overflow,
            ),
            Skeleton(
              width: width,
              height: style != null ? style.fontSize * 0.8 : 16 * 0.8,
            ),
          ],
        ),
      );
    }

    return CrossFadeWidgets(
        showFirst: showText,
        firstChild: textWidget ??
            Text(
              '',
              style: style,
              textAlign: textAlign,
              overflow: overflow,
            ),
        secondChild: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: children,
          ),
        ));
  }
}

class CrossFadeText extends StatelessWidget {
  final bool showText;
  final String text;
  final TextStyle style;
  final double width;

  const CrossFadeText(
    this.text, {
    Key key,
    @required this.showText,
    this.style,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CrossFadeWidgets(
        showFirst: showText,
        firstChild: Text(
          text ?? '',
          style: style,
          textAlign: TextAlign.left,
          overflow: TextOverflow.fade,
        ),
        secondChild: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            Text(
              ' ',
              style: style,
              textAlign: TextAlign.left,
            ),
            Skeleton(
              width: width,
              height: style != null ? style.fontSize * 0.8 : 16 * 0.8,
            ),
          ],
        ));
  }
}

class CrossFadeWidgets extends StatelessWidget {
  const CrossFadeWidgets({
    Key key,
    @required this.firstChild,
    @required this.secondChild,
    @required this.showFirst,
  }) : super(key: key);

  final Widget firstChild;
  final Widget secondChild;
  final bool showFirst;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      alignment: Alignment.topLeft,
      sizeCurve: Curves.fastOutSlowIn,
      firstCurve: Curves.fastOutSlowIn,
      secondCurve: Curves.fastOutSlowIn,
      firstChild: showFirst ? firstChild : secondChild,
      secondChild: secondChild,
      crossFadeState:
          showFirst ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: Duration(milliseconds: 300),
    );
  }
}

class BodyCard extends StatelessWidget {
  const BodyCard({
    Key key,
    @required this.gutters,
    @required this.article,
  }) : super(key: key);

  final double gutters;
  final Article article;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
      padding: EdgeInsets.all(gutters),
      child: Column(
        children: article.buildParagraphs(context),
      ),
    ));
  }
}

enum DrawerState { closed, closing, open, opening }

class Skeleton extends StatefulWidget {
  final double height;
  final double width;

  Skeleton({Key key, this.height = 20, this.width}) : super(key: key);

  createState() => SkeletonState();
}

class SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  Animation opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: Duration(milliseconds: 1500), vsync: this);

    opacity = Tween<double>(
      begin: .12,
      end: .26,
    ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceIn,
        reverseCurve: Curves.bounceOut))
      ..addListener(() {
        setState(() {});
      });

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.width,
        height: widget.height,
        decoration:
            BoxDecoration(color: Colors.black12.withOpacity(opacity.value)));
  }
}
