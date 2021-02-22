import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'classes.dart';

class ArticlePage extends StatefulWidget {
  final Article article;

  const ArticlePage({Key key, this.article}) : super(key: key);

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage>
    with SingleTickerProviderStateMixin {
  double width, height, usefulWidth, usefulHeight, margins, gutters;
  double appBarMargins;
  double maxContentWidth = 600;
  double contentWidth;
  double webLayoutMinWidth;
  double cardCornerRadius;
  double initialSheetHeight;
  double maxSheetHeight;
  double totalSheetHeightDelta;

  double imageScrollPosition = 0.0;

  bool isInitialized = false;
  bool isMobileLayout;
  bool isAppBarElevated = false;

  ScrollController scrollController = ScrollController();
  AnimationController appBarStateController;
  Animation<Color> appBarColor;
  Animation<Color> appBarForegroundColor;

  Future<String> testFuture;

  bool get displayMobileLayout {
    return isMobileLayout;
  }

  @override
  void initState() {
    scrollController.addListener(() {
      if (scrollController.offset > totalSheetHeightDelta) {
        appBarStateController.fling();
      } else if (isAppBarElevated) {
        appBarStateController.fling(velocity: -1);
      }
    });

    appBarStateController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    appBarStateController.addStatusListener((status) {
      if (status == AnimationStatus.completed)
        setState(() {
          isAppBarElevated = true;
        });
      else if (status == AnimationStatus.dismissed)
        setState(() {
          isAppBarElevated = false;
        });
    });
    appBarStateController.addListener(() {
      setState(() {});
    });

    testFuture = Future.delayed(
      Duration(seconds: 2),
      () => 'Large Latte',
    );

    super.initState();
  }

  void buildState(BuildContext context) {
    setState(() {
      Size size = MediaQuery.of(context).size;
      width = size.width;
      usefulWidth = size.width;
      height = size.height;

      usefulHeight = size.height - 56;

      maxSheetHeight = usefulHeight;
      initialSheetHeight = usefulHeight / 3;
      totalSheetHeightDelta = maxSheetHeight - initialSheetHeight;

      if (width < 720) {
        gutters = 24;
        appBarMargins = 0;
      } else {
        gutters = 24;
        appBarMargins = 24;
      }

      webLayoutMinWidth = maxContentWidth + gutters * 2;

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

      if (!isInitialized) {
        appBarColor = ColorTween(
                begin: Colors.transparent,
                end: Color.alphaBlend(Colors.white.withOpacity(.09),
                    Theme.of(context).colorScheme.background))
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
      }

      isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    buildState(context);

    return FutureBuilder(
        future: widget.article.load(),
        builder: (context, snapshot) {
          if (!widget.article.isLoaded)
            return Scaffold(
                appBar: AppBar(
                  // elevation: appBarStateController.value * 4,
                  shadowColor: Colors.black.withOpacity(
                      appBarStateController.value *
                          appBarStateController.value),
                  backgroundColor: appBarColor.value,
                  backwardsCompatibility: false,
                  // foregroundColor: appBarForegroundColor.value,
                  leadingWidth: 56 + appBarMargins,
                  leading: IconButton(
                    icon: IconShadowWidget(
                      Icon(Icons.arrow_back),
                      showShadow: false,
                      shadowColor: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  title: Text(
                    widget.article.title,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(appBarStateController.value * .87)),
                  ),
                ),
                body: Center(child: CircularProgressIndicator()));
          else
            return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                // elevation: appBarStateController.value * 4,
                shadowColor: Colors.black.withOpacity(
                    appBarStateController.value * appBarStateController.value),
                backgroundColor: appBarColor.value,
                backwardsCompatibility: false,
                foregroundColor: appBarForegroundColor.value,
                leadingWidth: 56 + appBarMargins,
                leading: IconButton(
                  icon: IconShadowWidget(
                    Icon(Icons.arrow_back, color: appBarForegroundColor.value),
                    showShadow: appBarStateController.isDismissed,
                    shadowColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(
                  widget.article.title,
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.headline6.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(appBarStateController.value * .87)),
                ),
              ),
              body: NotificationListener(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification)
                    setState(() =>
                        imageScrollPosition -= notification.scrollDelta / 4);
                },
                child: Stack(
                  children: [
                    Positioned(
                      top: imageScrollPosition,
                      child: // Container()
                          ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: usefulWidth,
                            minWidth: usefulWidth,
                            minHeight: height * 2 / 3,
                            maxHeight: height),
                        child: Material(
                          elevation: 4,
                          child: Image.network(
                            widget.article.imageUrl,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            // width: usefulWidth,
                            // height: height,
                            semanticLabel: widget.article.altText,
                            frameBuilder: (BuildContext context, Widget child,
                                int frame, bool wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded ?? false) {
                                return child;
                              }
                              return AnimatedOpacity(
                                child: child,
                                opacity: frame == null ? 0 : 1,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeIn,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Scrollbar(
                      // thickness: 4,
                      isAlwaysShown: !displayMobileLayout,
                      controller: scrollController,
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: margins, right: margins),
                          child: Column(
                            // verticalDirection: VerticalDirection.up,
                            children: [
                              buildTitles(context),
                              Card(
                                elevation: 4,
                                margin: EdgeInsets.only(bottom: gutters),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        cardCornerRadius)),
                                child: Padding(
                                  padding: EdgeInsets.all(gutters),
                                  child: Column(
                                      children: widget.article.buildParagraphs(
                                          context,
                                          textAlign: TextAlign.left)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
        });
  }

  Widget buildTitles(BuildContext context) {
    var marginLeft = 0.0;
    if (margins + marginLeft < appBarMargins + 72) {
      marginLeft = marginLeft + appBarMargins + 72 - (margins + marginLeft);
    }
    return PreferredSize(
      preferredSize: Size.fromHeight(height / 2),
      // constraints: BoxConstraints(minHeight: height / 2),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: height / 2),
        child: Container(
          decoration: BoxDecoration(
              gradient: RadialGradient(
                  center: Alignment(0.0, 1.2),
                  radius: 0.8,
                  colors: <Color>[Colors.black, Colors.transparent])),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: gutters,
                top: gutters,
                left: marginLeft,
                right: marginLeft),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AutoSizeText(
                  widget.article.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  minFontSize: 10,
                  style: Theme.of(context).textTheme.headline3.copyWith(
                    color: Color.alphaBlend(
                        Colors.white.withOpacity(.87), Colors.black),
                    shadows: <Shadow>[
                      Shadow(
                        blurRadius: 3.0,
                        color: Colors.black38,
                      ),
                      Shadow(
                        blurRadius: 8.0,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                if (widget.article.subtitle != null)
                  AutoSizeText(
                    widget.article.subtitle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.headline6.copyWith(
                      color: Color.alphaBlend(
                          Colors.white.withOpacity(.6), Colors.black),
                      shadows: <Shadow>[
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.black38,
                        ),
                        Shadow(
                          blurRadius: 8.0,
                          color: Colors.black38,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
